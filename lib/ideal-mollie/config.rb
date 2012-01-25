#
# Configuration object for storing some parameters required for making transactions
#
module IdealMollie::Config
  class << self
    attr_accessor :partner_id, :report_url, :return_url, :test_mode

    # Set's the default value's to nil and false
    def init!
      @defaults = {
        :@partner_id => nil,
        :@report_url => nil,
        :@return_url => nil,
        :@test_mode => false
      }
    end

    # Resets the value's to there previous value (instance_variable)
    def reset!
      @defaults.each { |key, value| instance_variable_set(key, value) }
    end

    # Set's the new value's as instance variables
    def update!
      @defaults.each do |key, value|
        instance_variable_set(key, value) unless instance_variable_defined?(key)
      end
    end
  end
  init!
  reset!
end
