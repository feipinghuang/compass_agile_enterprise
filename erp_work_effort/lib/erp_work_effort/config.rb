module ErpWorkEffort
  module Config
    class << self

      attr_accessor :days_per_month, :days_per_week, :hours_per_day

      def init!
        @defaults = {
          :@days_per_month => 20,
          :@days_per_week => 5,
          :@hours_per_day => 8
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
