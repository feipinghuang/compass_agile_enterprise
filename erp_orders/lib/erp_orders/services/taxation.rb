require 'yaml'

module ErpOrders
  module Services
    class Taxation

      def calculate_tax!(taxed_record, ctx)

        if ctx[:is_online_sale]
          calculate_online_tax(taxed_record, ctx)
        end

      end

      protected

      # for online sales tax is only applied if the item purchased is being shipped to the
      # same state the product is being shipped from
      def calculate_online_tax(taxed_record, ctx)
        taxes = nil

        # make sure the taxes config file exists
        if File.exists?(File.join(Rails.root, 'config', 'taxes.yml'))
          # use yaml file for now, eventually needs to be updated to use tax service
          tax_config = YAML.load_file(File.join(Rails.root, 'config', 'taxes.yml')).symbolize_keys

          # If there is an origin and a destination and the state of the origin is the same as the destination then apply apply taxes
          if ctx[:origin_address] &&
              ctx[:origin_address][:state] &&
              ctx[:destination_address] &&
              ctx[:destination_address][:state] &&
              (ctx[:origin_address][:state] == ctx[:destination_address][:state])

            taxes = (tax_config[:state_tax_rate] * ctx[:amount]).round(2)
            taxed_record.taxed = true
            taxed_record.sales_tax = taxes
            taxed_record.save!

            # create a tax line to record the tax rate
            if taxed_record.sales_tax_lines.empty?
              sales_tax_line = SalesTaxLine.new
              sales_tax_line.taxed_record = taxed_record
            else
              sales_tax_line = taxed_record.sales_tax_lines.first
            end

            sales_tax_line.rate = tax_config[:state_tax_rate]
            sales_tax_line.save!

          end
        end

        # if taxes could not be determined assume taxes are 0
        if taxes.nil?
          taxes = 0
          taxed_record.taxed = false
          taxed_record.sales_tax = taxes
          taxed_record.save
        end

        taxes
      end

    end # Taxation
  end # Services
end # ErpOrders
