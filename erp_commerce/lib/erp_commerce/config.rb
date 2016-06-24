module ErpCommerce
  module Config
    class << self
      
      attr_accessor :encryption_key, :capture_payments

      def init!
        @defaults = {
          :@encryption_key => 'cd6fae94-9c2f-11e4-89d3-123b93f75cba',
          :@capture_payments => true
        }
      end

      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end
      end

      def configure(&blk)
        @configure_blk = blk
      end

      def configure!
        @configure_blk.call(self) if @configure_blk
      end
    end
    init!
    reset!
  end
end
