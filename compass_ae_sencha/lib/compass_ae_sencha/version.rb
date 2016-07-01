module CompassAeSencha
  module VERSION #:nodoc:
    MAJOR = 2
    MINOR = 2
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end

  def self.version
    CompassAeSencha::VERSION::STRING
  end
end

