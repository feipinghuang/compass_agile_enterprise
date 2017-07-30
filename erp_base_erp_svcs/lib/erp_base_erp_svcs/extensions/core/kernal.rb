module Kernel
  def eigenclass
    class << self
      self
    end
  end
end