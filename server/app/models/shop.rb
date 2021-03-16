class Shop < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :prices
  has_many :products, through: :prices
end
