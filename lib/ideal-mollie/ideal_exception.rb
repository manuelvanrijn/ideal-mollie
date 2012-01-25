module IdealMollie
  #
  # Exception class specific for the IdealMollie error that might occur
  #
  class IdealException < Exception
    # @return [String] The errorcode
    attr_accessor :errorcode
    # @return [String] The error description
    attr_accessor :message
    # @return [String] The error type
    attr_accessor :type

    # @param [String] errorcode The error code
    # @param [String] message The error message
    # @param [String] type The error type
    def initialize(errorcode, message, type)
      self.errorcode = errorcode
      self.message = message
      self.type = type
    end
  end
end
