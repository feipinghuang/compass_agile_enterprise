require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class GenerateApiDocs

      def self.execute
        new()
      end

      def initialize
        options = {gems: nil}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass_ae-dev generate_api_docs [OPTIONS]"

          opt.on("-g", "--gems [GEMLIST]", Array,
                 "List of gems to build; defaults to all") {|gem| options[:gems] = gem}

          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:gems]) do |engine_name|
          if Dir.exists? File.join(Dir.pwd, 'app', 'controllers', 'api', 'v1')
            if Dir.exists? File.join(Dir.pwd, 'public', 'docs', 'api', 'v1', engine_name)

              Dir.chdir(File.join(Dir.pwd, 'public', 'docs', 'api', 'v1', engine_name))

              result = %x[apidoc-swagger -i ../../../../../app/controllers/api/v1/ -o ./ --markdown=false]
              puts result
            else
              puts "#{engine_name} does not have a public API docs directory"
            end
          else
            puts "#{engine_name} does not have any API/V1 controllers"
          end

          puts "\n"
        end # ErpDevSvcs::Commands::Helper.exec_in_engines
      end # initialize

    end # GenerateApiDocs
  end # Commands
end # ErpDevSvcs
