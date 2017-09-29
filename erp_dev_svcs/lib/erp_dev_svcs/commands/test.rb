require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class Test

      def self.execute
        new()
      end

      def initialize
        options = {:gems => nil}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass_ae-dev test [OPTIONS]"

          opt.on("-g", "--gems [GEMLIST]", Array,
                 "List of engines to test;"\
                 "defaults to all") {|gem| options[:gems] = gem}

          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        return_code = 0;

        unless Dir.exists? 'coverage'
          system('mkdir ./coverage')
        end

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:gems]) do |engine_name|
          puts "\nRunning #{engine_name}'s test suite...  \n"
          puts system('bundle exec rspec --tty --color spec')

          unless Dir.exists? '../coverage/' + engine_name
            system('mkdir ../coverage/' + engine_name)
          end
          system('cp -r ./coverage/ ../coverage/' + engine_name)

          if $?.exitstatus != 0
            return_code = $?.exitstatus
          end
        end

        exit(return_code)
      end

    end # Test
  end # Commands
end # ErpDevSvcs
