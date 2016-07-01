module ErpAgreements
  module VERSION #:nodoc:
    MAJOR = 4
    MINOR = 2
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end

  def self.version
    ErpAgreements::VERSION::STRING
  end
end
