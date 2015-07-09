module StringToBoolean
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

module StringToInternalIdentifier
  def to_iid
    iid = self.gsub(' ', '_').tr('^A-Za-z0-9_', '').downcase

    #remove trailing _
    if iid[-1] == '_'
      iid.chop!
    end

    iid
  end
end

module IsInteger
  def is_integer?
    /\A[-+]?\d+\z/ === self
  end
end

class String;
  include StringToBoolean
  include StringToInternalIdentifier
  include IsInteger
end

module BooleanToBoolean
  def to_bool;
    return self;
  end
end

class TrueClass;
  include BooleanToBoolean;
end
class FalseClass;
  include BooleanToBoolean;
end