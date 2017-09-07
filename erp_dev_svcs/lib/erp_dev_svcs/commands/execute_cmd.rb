require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class ExecuteCmd

      def self.execute
        new()
      end

      def initialize
        ErpDevSvcs::Commands::Helper.exec_in_engines do
          result = %x[#{ARGV.join(' ')}]
          puts result
        end
      end
    end
  end
end
