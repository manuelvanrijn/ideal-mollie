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
  # @param [int] amount The amount of money to transfer (defined in cents).
  # @param [String] description The description of the payment on the bank transfer.
  # @param [String] bank_id The id of the bank selected from one of the supported banks.
  #
  # @example
  #   IdealMollie.new_order(1000, "Ordernumber #123: new gadget", "0031")
  #
  # @return [IdealMollie::Order] the +Order+.
  def self.new_order(amount, description, bank_id)
    response = IdealMollie.request("fetch", {
      :partnerid => Config.partner_id,
      :reporturl => Config.report_url,
      :returnurl => Config.return_url,
      :description => description,
      :amount => amount,
      :bank_id => bank_id
    })

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
  # @note Once a transaction is payed, only the next time you verify the
  #   transaction will the value of +payed+ be +true+.
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

    private

    def connection
      @connection ||= Faraday::Connection.new(:url => "https://secure.mollie.nl/xml/ideal",
                                  :headers => {:user_agent => "Ruby-IdealMollie"},
                                  :ssl => {:verify => false}) do |builder|
        builder.adapter Faraday.default_adapter
        builder.use FaradayMiddleware::ParseXml
      end
    end
  end
end
