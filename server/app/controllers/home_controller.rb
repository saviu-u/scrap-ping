class HomeController < ApplicationController
  def index
    response = {
      products: products,
      categories: categories,
      shops: shops
    }
    render_json(response, 200)
  end

  def products
    Category.includes(products: [prices: :shop]).limit(3).map do |category|
      { category.title => category.retrieve_products }
    end
  end

  def categories
    Category.all.map(&:to_show)
  end

  def shops
    Shop.all.map(&:to_index)
  end
end
