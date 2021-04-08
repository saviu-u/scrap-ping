class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :products

  def to_show
    {
      title: title,
      id: slug
    }
  end

  def retrieve_products(limit = 5)
    products[0..limit-1].map(&:to_show)
  end
end
