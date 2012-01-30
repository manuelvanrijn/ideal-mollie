#
# Configuration object for storing some parameters required for making transactions
#
module IdealMollie::Config
  class << self
    # @return [int] Your Mollie partner id.
    # @note See: https://www.mollie.nl/beheer/betaaldiensten/documentatie/ideal/ for your partner id
    attr_accessor :partner_id
    # @return [int] Your Mollie profile key
    # @note The is a optional parameter. You only need this if you have multiple profiles
    # @note See: https://www.mollie.nl/beheer/betaaldiensten/profielen/ for the list of profiles
    attr_accessor :profile_key
    # @return [String] The url Mollie uses to report the status of the payment
    attr_accessor :report_url
    # @return [String] The url Mollie sends you to when a transaction is finished
    attr_accessor :return_url
    # @return [Boolean] Test mode switch
    attr_accessor :test_mode

    # Set's the default value's to nil and false
    # @return [Hash] configuration options
    def init!
      @defaults = {
        :@partner_id => nil,
        :@profile_key => nil,
        :@report_url => nil,
        :@return_url => nil,
        :@test_mode => false
      }
    end

    # Resets the value's to there previous value (instance_variable)
    # @return [Hash] configuration options
    def reset!
      @defaults.each { |key, value| instance_variable_set(key, value) }
    end

    # Set's the new value's as instance variables
    # @return [Hash] configuration options
    def update!
      @defaults.each do |key, value|
        instance_variable_set(key, value) unless instance_variable_defined?(key)
      end
    end
  end
  init!
  reset!
end
