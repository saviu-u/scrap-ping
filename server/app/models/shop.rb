class Shop < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :prices
  has_many :products, through: :prices

  def to_show
    {
      title: title,
      image_path: image_path
    }
  end

  def to_index
    to_show.merge!({ link: link || spider.new.host })
  end

  def spider
    spider_name.constantize
  end

  def search_item item
    spider.new(item).import
  end
end
