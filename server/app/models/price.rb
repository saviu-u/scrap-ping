class Price < ApplicationRecord
  belongs_to :shop
  belongs_to :product

  def spider_class
    @spider_class ||= "Spider::#{spider_name}".constantize
  end

  def price_update
    shop.spider.new.update(id_integration, self)
  end

  def to_show
    {
      price: price,
      price_shop: shop&.to_show,
      price_link: link
    }
  end
end