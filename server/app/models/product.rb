class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :category
  has_many :prices
  has_many :shops, through: :prices
end
