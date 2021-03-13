class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :category
  has_many :shops, through: :price

  def spider_class
    @spider_class ||= "Spider::#{spider_name}".constantize
  end
end
