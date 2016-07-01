module RailsDbAdmin
  module VERSION #:nodoc:
    MAJOR = 3
    MINOR = 2
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end

  def self.version
    RailsDbAdmin::VERSION::STRING
  end
end
