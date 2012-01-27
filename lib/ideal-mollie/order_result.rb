module IdealMollie
  #
  # Object representing a "OrderResult" object with attributes provided by Mollie
  #
  # @example
  #   Order.new({
  #     :transaction_id => "4b99662febb42ce6f889d9c57f5cf3fa",
  #     :amount => 1465,
  #     :currency => "EUR",
  #     :payed => true,
  #     :consumer => {
  #       :consumerName => "Hr J Janssen",
  #       :consumerAccount => "P001234567",
  #       :consumerCity => "Amsterdam"
  #     },
  #     :message => "This iDEAL-order has successfuly been payed for,
  #                  and this is the first time you check it.",
  #     :status => "Expired"
  #   })
  class OrderResult < Order
    # @return [Boolean] Order was paid.
    attr_accessor :paid
    # @return [String] The name of the customer.
    attr_accessor :customer_name
    # @return [String] The bankaccount number of the customer.
    attr_accessor :customer_account
    # @return [String] The city of the customer.
    attr_accessor :customer_city
    # @return [String] Status of the Order.
    attr_accessor :status

    #
    # Initializer to transform a +Hash+ into an OrderResult object
    #
    # @param [Hash] values
    def initialize(values=nil)
      return if values.nil?

      super(values)

      @paid = values["payed"] == "true" ? true : false if values.has_key?("payed")
      @status = values["status"].to_s if values.has_key?("status")

      if values.has_key?("consumer")
        consumer = values["consumer"]
        @customer_name = consumer["consumerName"].to_s if consumer.has_key?("consumerName")
        @customer_account = consumer["consumerAccount"].to_s if consumer.has_key?("consumerAccount")
        @customer_city = consumer["consumerCity"].to_s if consumer.has_key?("consumerCity")
      end
    end
  end
end
