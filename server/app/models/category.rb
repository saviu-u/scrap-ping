class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :products

  def to_index
    {
      title: title,
      id: slug
    }
  end

  def retrieve_products(limit = 5)
    products.select{ |product| product.prices.any?(&:active) }[0..limit-1].map(&:to_index)
  end
end
