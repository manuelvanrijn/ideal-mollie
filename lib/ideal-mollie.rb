# Gems
require "faraday"
require "faraday_middleware"
require "multi_xml"

# Files
require "ideal-mollie/bank"
require "ideal-mollie/config"
require "ideal-mollie/engine" if defined?(Rails) && Rails::VERSION::MAJOR == 3
require "ideal-mollie/ideal_exception"
require "ideal-mollie/order"
require "ideal-mollie/order_result"

#
# IdealMollie Module
#
module IdealMollie
  # Mollie API url
  MOLLIE_URL = "https://secure.mollie.nl/xml/ideal"

  #
  # List of supported banks.
  #
  # @visibility public
  #
  # @example
  #   IdealMollie.banks
  #
  # @return [Array<IdealMollie::Bank>] list of supported +Bank+'s.
  def self.banks
    response = IdealMollie.request("banklist")

    banks = response["bank"]
    banks = [banks] unless banks.is_a?Array # to array if it isn't already

    banks.inject([]) { |result, bank| result << IdealMollie::Bank.new(bank); result }
  end

  #
  # Create a new order.
  #
  # @visibility public
  #
  # @param [Hash or int] hash_or_amount The amount of money to transfer (defined in cents) or a Hash.
  # @param [String] description The description of the payment on the bank transfer.
  # @param [String] bank_id The id of the bank selected from one of the supported banks.
  # @param [String] return_url Optional override of the return url specified in the Config
  #
  # @example
  #   # as a Hash
  #   IdealMollie.new_order(amount: 1000, description: "Ordernumber #123: new gadget", bank_id: "0031")
  #   IdealMollie.new_order(
  #     amount: 1000,
  #     description: "Ordernumber #123: new gadget",
  #     bank_id: "0031",
  #     return_url: "http://override.url/controller/return_action",
  #     report_url: "http://override.url/controller/report_action"
  #   )
  #
  #   # as arguments
  #   IdealMollie.new_order(1000, "Ordernumber #123: new gadget", "0031")
  #   IdealMollie.new_order(1000, "Ordernumber #123: new gadget", "0031", "http://override.url/controller/return_action")
  #   IdealMollie.new_order(1000, "Ordernumber #123: new gadget", "0031", "http://override.url/controller/return_action", "http://override.url/controller/report_action")
  #
  # @return [IdealMollie::Order] the +Order+.
  def self.new_order(hash_or_amount, description=nil, bank_id=nil, return_url=nil, report_url=nil)
    amount = hash_or_amount
    if hash_or_amount.is_a?(Hash)
      amount = hash_or_amount[:amount]
      description = hash_or_amount[:description]
      bank_id = hash_or_amount[:bank_id]
      return_url = hash_or_amount[:return_url] if hash_or_amount.has_key?(:return_url)
      report_url = hash_or_amount[:report_url] if hash_or_amount.has_key?(:report_url)
    end
    params = new_order_params(amount, description, bank_id, return_url, report_url)
    response = IdealMollie.request("fetch", params)

    IdealMollie::Order.new(response["order"])
  end

  #
  # Check the status of a order.
  #
  # @visibility public
  #
  # @param [String] transaction_id the transaction to verify.
  #
  # @example
  #   IdealMollie.check_order("4b99662febb42ce6f889d9c57f5cf3fa")
  #
  # @note Once a transaction is paid, only the next time you verify the
  #   transaction will the value of +paid+ be +true+.
  #   Else it will be +false+.
  #
  # @return [IdealMollie::OrderResult] the +OrderResult+.
  def self.check_order(transaction_id)
    response = IdealMollie.request("check", {
      :partnerid => Config.partner_id,
      :transaction_id => transaction_id
    })
    IdealMollie::OrderResult.new(response["order"])
  end

  class << self
    MultiXml.parser = :nokogiri

    #
    # Perform a request to the https xlm server of mollie and return the responded xml
    # which is converted to an hash
    #
    # @param [String] action The action to perform.
    # @param [Hash] params Additional parameters to send like partner_id
    #
    # @raise [IdealMollie::IdealException] When a error is returned by Mollie
    #
    # @return [Hash] the returned XML as a +Hash+
    def request(action, params={})
      params.merge!(:a => action)
      params.merge!(:testmode => Config.test_mode)
      request = connection.post do |req|
        req.url("", params)
      end
      response = request.body["response"]

      if response.has_key?("item")
        error = response["item"]
        raise IdealMollie::IdealException.new(error["errorcode"], error["message"], error["type"])
      end
      response
    end

    #
    # Builds a +Hash+ with the parameters, that are needed for making a new order
    # Makes sure the +return_url+ is set to the correct value
    #
    # @param [int] amount The amount of money to transfer (defined in cents).
    # @param [String] description The description of the payment on the bank transfer.
    # @param [String] bank_id The id of the bank selected from one of the supported banks.
    # @param [String] return_url Optional override of the return url specified in the Config
    #
    # @return [Hash] the parameter +Hash+ for the new order.
    def new_order_params(amount, description, bank_id, return_url=nil, report_url=nil)
      return_url = Config.return_url if return_url.nil?
      report_url = Config.report_url if report_url.nil?

      params = {
        :partnerid => Config.partner_id,
        :reporturl => report_url,
        :returnurl => return_url,
        :description => description,
        :amount => amount,
        :bank_id => bank_id
      }

      unless Config.profile_key.nil?
        params.merge!({:profile_key => Config.profile_key})
      end

      params
    end

    private

    def connection
      @connection ||= Faraday::Connection.new(:url => IdealMollie::MOLLIE_URL,
                                  :headers => {:user_agent => "Ruby-IdealMollie"},
                                  :ssl => {:verify => false}) do |builder|
        builder.adapter Faraday.default_adapter
        builder.use FaradayMiddleware::ParseXml
      end
    end
  end
end
