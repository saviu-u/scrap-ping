class SearchController < ApplicationController
  def search
    render_json(
      {
        products: paginate.map(&:to_index),
        tags: search_resources.fancy_tags,
        fixed_price: search_resources.price_range
      }.merge(metadata: metadata)
    )
  end

  private

  def load_search
    @load_search ||= params.permit(:search)[:search]
  end

  def search_resources
    return Product.none unless load_search
    return @search_resources if @search_resources

    @search_resources = Product.joins(:prices, :category).includes(prices: :shop)
  end

  def resources
    @resources ||= search_resources.where(permitted_params)
                                   .for_search(load_search, params.permit(tags: {})[:tags])
  end

  def permitted_params
    return @permitted_params if @permitted_params

    price = params.permit(:price_gteq, :price_lteq)
    price = ((price[:price_gteq] || 0)..params[:price_lteq])

    @permitted_params = {}
    @permitted_params[:prices] = { price: price }
    @permitted_params
  end
end
