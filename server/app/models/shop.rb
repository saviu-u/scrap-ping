class Shop < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :prices
  has_many :products, through: :prices

  def spider
    spider_name.constantize
  end

  def search_item item
    spider.new(item).import
  end
end
