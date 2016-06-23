ProductOption.class_eval do
  acts_as_priceable
end

module ErpCommerce
  module Extensions
    module ProductOptionExtension

      def price
        self.get_default_price ? self.get_default_price.money.amount : nil
      end

      # Override from base class, converts model to data hash
      #
      # @return [Hash] Data hash for this model
      def to_data_hash
        data = super

        data[:price] = self.price

        data
      end
      alias :to_mobile_data_hash :to_data_hash

    end # ProductOptionExtension
  end # Extensions
end # CompassAeBusinessSuite

ProductOption.prepend ErpCommerce::Extensions::ProductOptionExtension