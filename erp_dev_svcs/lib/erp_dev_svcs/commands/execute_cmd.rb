require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class ExecuteCmd

      def self.execute
        new()
      end

      def initialize
        return_code = 0;

        ErpDevSvcs::Commands::Helper.exec_in_engines do
          puts = system("#{ARGV.join(' ')}")

          if $?.exitstatus != 0
            return_code = $?.exitstatus
          end
        end

        exit(return_code)
      end # initialize

    end # ExecuteCmd
  end # Commands
end # ErpDevSvcs
