module IdealMollie
  #
  # Exception class specific for the IdealMollie error that might occur
  #
  class IdealException < Exception
    attr_accessor :errorcode, :message, :type

    # @param [String] errorcode The errorcode
    # @param [String] message The error description
    # @param [String] type The error type
    def initialize(errorcode, message, type)
      self.errorcode = errorcode
      self.message = message
      self.type = type
    end
  end
end
