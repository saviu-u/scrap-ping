class ProductTag < ApplicationRecord
  belongs_to :product
  belongs_to :tag

  accepts_nested_attributes_for :tag

  def to_show
    { label: tag.title, value: value }
  end
end
