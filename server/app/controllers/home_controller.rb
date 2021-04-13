class HomeController < ApplicationController
  def index
    render_json(
      {
        products: products,
        categories: categories,
        shops: shops
      }
    )
  end

  private

  def products
    Category.includes(products: [prices: :shop]).limit(3).map do |category|
      { category.title => category.retrieve_products }
    end
  end

  def categories
    Category.all.map(&:to_index)
  end

  def shops
    Shop.all.map(&:to_index)
  end
end