class CategoryClassification < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :classification, :polymorphic => true
  belongs_to :category

  def to_data_hash
    data = to_hash(only: [:id, :created_at, :updated_at, :classification_type, :classification_id])

    data[:category] = self.category.to_data_hash

    data
  end
end
