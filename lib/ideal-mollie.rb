# Gems
require "faraday"
require "faraday_middleware"
require "multi_xml"

# Files
require "ideal-mollie/config"
require "ideal-mollie/ideal_exception"
require "ideal-mollie/engine" if defined?(Rails) && Rails::VERSION::MAJOR == 3

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
  #   # => [{:id=>"9999", :name=>"TBM Bank"}, ...]
  #
  # @return [Array] list of supported banks.
  def self.banks
    response = IdealMollie.request("banklist")

    banks = response["bank"]
    banks = [banks] unless banks.is_a?Array # to array if it isn't already

    banks.map do |bank|
      {:id => bank["bank_id"], :name => bank["bank_name"]}
    end
  end

  #
  # Create a new payment
  #
  # @visibility public
  #
  # @param [int] amount The amount of money to transfer (defined in cents).
  # @param [String] description The description of the payment on the bank transfer.
  # @param [String] bank_id The id of the bank selected from one of the supported banks.
  #
  # @example
  #
  #   IdealMollie.new_payment(1000, "Ordernumber #123: new gadget", "0031")
  #   # => {
  #   #       :transaction_id=>"72457c865d4b800eb8b0f3ba928ff495",
  #   #       :amount=>1000,
  #   #       :currency=>"EUR",
  #   #       :URL=>"http://www.mollie.nl/partners/ideal-test-bank?order_nr=M738907M05885973&transaction_id=72457c865d4b800eb8b0f3ba928ff495&trxid=0073890705885973",
  #   #       :message=>"Your iDEAL-payment has successfully been setup. Your customer should visit the given URL to make the payment"
  #   #    }
  #
  # @return [Hash] the transaction object
  def self.new_payment(amount, description, bank_id)
    response = IdealMollie.request("fetch", {
      :partnerid => Config.partner_id,
      :reporturl => Config.report_url,
      :returnurl => Config.return_url,
      :description => description,
      :amount => amount,
      :bank_id => bank_id
    })
    order = response["order"]

    result = {
      :transaction_id => order["transaction_id"],
      :amount => order["amount"].to_i,
      :currency => order["currency"],
      :url => order["URL"],
      :message => order["message"]
    }
    result
  end

  #
  # Check the status of a transaction.
  #
  # @visibility public
  #
  # @param [String] transaction_id the transaction to verify.
  #
  # @example
  #   IdealMollie.check_payment("4b99662febb42ce6f889d9c57f5cf3fa")
  #   # => {
  #   #        :transaction_id => '4b99662febb42ce6f889d9c57f5cf3fa',
  #   #        :amount => 1465,
  #   #        :currency => "EUR",
  #   #        :payed => true,
  #   #        :consumer => {
  #   #          :name => "Hr J Janssen",
  #   #          :account => "P001234567",
  #   #          :city => "Amsterdam"
  #   #        },
  #   #        :message => "This iDEAL-order has successfuly been payed for,
  #   #                     and this is the first time you check it.",
  #   #        :status => "Expired"
  #   #      }
  #
  # @note Once a transaction is payed, only the next time you verify the
  #   transaction will the value of 'payed' be 'true'.
  #   Else it will be 'false'.
  #
  # @return [Hash] the status of the transaction.
  def self.check_payment(transaction_id)
    response = IdealMollie.request("check", {
      :partnerid => Config.partner_id,
      :transaction_id => transaction_id
    })
    order = response["order"]

    result = {
      :transaction_id => order["transaction_id"],
      :amount => order["amount"].to_i,
      :currency => order["currency"],
      :payed => order["payed"] == "true" ? true : false,
      :message => order["message"],
      :status => order["status"]
    }
    if order.has_key?("consumer")
      consumer = order["consumer"]
      result.merge!(:consumer => {
        :name => consumer["consumerName"],
        :account => consumer["consumerAccount"],
        :city => consumer["consumerCity"]
      })
    end
    result
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
    # @return [Hash] the returned XML as a Hash
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
