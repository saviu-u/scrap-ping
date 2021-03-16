class Price < ApplicationRecord
  belongs_to :shop
  belongs_to :product

  def spider_class
    @spider_class ||= "Spider::#{spider_name}".constantize
  end

  def update_info
    # spider_class.
  end
end