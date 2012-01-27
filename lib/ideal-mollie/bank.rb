module IdealMollie
  #
  # Object representing a "Bank" object with attributes provided by Mollie
  #
  # @example
  #   Bank.new({
  #     :bank_id => "0031",
  #     :bank_name => "ABN AMRO"
  #   })
  class Bank
    # @return [String] The id of the bank provided by Mollie.
    attr_accessor :id
    # @return [String] The name of the bank.
    attr_accessor :name

    #
    # Initializer to transform a +Hash+ into an Bank object
    #
    # @param [Hash] values
    def initialize(values=nil)
      return if values.nil?

      @id = values["bank_id"].to_s
      @name = values["bank_name"].to_s
    end
  end
end
