require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class RunBrakeman

      def self.execute
        new()
      end

      def initialize
        options = {gems: nil}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass_ae-dev run_brakeman [OPTIONS]"

          opt.on("-b", "--brakeman_opts [GEMLIST]") do |args|
            options[:breakman_options] = args
          end

          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:gems]) do |engine_name|
          puts "Running Brakeman in #{engine_name}"

          result = %x[brakeman -o brakeman.txt #{options[:breakman_options]}]
          puts result

          puts "\n"
        end # ErpDevSvcs::Commands::Helper.exec_in_engines
      end # initialize

    end # RunBrakeman
  end # Commands
end # ErpDevSvcs
