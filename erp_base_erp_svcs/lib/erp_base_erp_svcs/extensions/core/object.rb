module ErpBaseErpSvcs
  module Refinements

    refine Object do

      def eigenclass
        class << self; self; end
      end

    end # Kernel

  end # Refinements
end # ErpBaseErpSvcs


Object.instance_eval do
  def all_subclasses
    klasses = self.subclasses
    (klasses | klasses.collect do |klass| klass.all_subclasses end).flatten.uniq
  end

  # Check if a class exists
  #
  # @param class_name [String] name of class to check
  def class_exists?(class_name)
    class_name.to_s.constantize
    # try to constantize twice which will cause false positives for Rails Models to fail
    class_name.to_s.constantize
    true
  rescue NameError
    false
  end
end
