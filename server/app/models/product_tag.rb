class ProductTag < ApplicationRecord
  belongs_to :product
  belongs_to :tag

  accepts_nested_attributes_for :tag
end
