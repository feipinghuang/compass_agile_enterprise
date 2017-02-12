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
        # use yaml file for now, eventually needs to be updated to use tax service
        tax_service = YAML.load_file(File.join(Rails.root, 'config', 'taxes.yml')).symbolize_keys

        # if the origin state is the same as the destination state
        # determine taxes else taxes are 0
        if ctx[:destination_address].nil? or ctx[:destination_address][:state].nil? or (ctx[:origin_address][:state] == ctx[:destination_address][:state])
          taxes = (tax_service[:state_tax_rate] * ctx[:amount]).round(2)
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

          sales_tax_line.rate = tax_service[:state_tax_rate]
          sales_tax_line.save!
        else
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
