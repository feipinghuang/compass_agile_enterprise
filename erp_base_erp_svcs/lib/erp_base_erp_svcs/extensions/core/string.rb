module StringToBoolean
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

module StringToInternalIdentifier
  def to_iid
    iid = self.squish.gsub(' ', '_').tr('^A-Za-z0-9_', '').downcase

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


module IsDecimal
  def is_decimal?
    /^[0-9]+(\.[0-9]+)?$/ === self
  end
end

module RandomString
  def random(size=25)
    charset = %w{A C D E F G H J K M N P Q R T V W X Y Z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end
end

class String;
  include StringToBoolean
  include StringToInternalIdentifier
  include IsInteger
  include IsDecimal
  extend RandomString
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