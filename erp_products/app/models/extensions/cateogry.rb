module ErpProducts
  module Extensions

    module Category

      def to_data_hash
        data = super

        data[:product_type_count] = ::CategoryClassification.where('classification_type = ?', 'ProductType').
                                        where(category_id: self.id).count('id')

        data
      end

    end

  end
end

Category.class_eval do
  prepend ErpProducts::Extensions::Category
end
