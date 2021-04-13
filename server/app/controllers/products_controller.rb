class ProductsController < ApplicationController
  before_action :load_product

  def show
    render_json(load_product.to_show)
  end

  private

  def load_product
    @load_product = Product.friendly.find(params[:id])
  end
end
