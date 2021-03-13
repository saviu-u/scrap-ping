class Shop < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :products, through: :price
end
