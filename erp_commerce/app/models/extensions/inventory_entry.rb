InventoryEntry.class_eval do
  acts_as_priceable
end

module ErpCommerce
  module Extensions
    module InventoryEntryExtension

      # Override from base class, converts model to data hash
      #
      # @return [Hash] Data hash for this model
      def to_data_hash
        data = super

        if get_default_price
          data[:price] = get_default_price.try(:money).try(:amount)
        end

        data
      end

    end # UserExtension
  end # Extensions
end # ErpCommerce

InventoryEntry.prepend ErpCommerce::Extensions::InventoryEntryExtension
