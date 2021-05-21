class CategoryController < SearchController
  def search_resources
    return render_json({}, 404) unless load_search
    return @search_resources if @search_resources

    @search_resources = Category.friendly.find(load_search).products.joins(:prices, :category).includes(prices: :shop)
  end

  def resources
    @resources ||= search_resources.where(permitted_params)
                                   .for_search(load_search, params.permit(tags: {})[:tags])
  end
end
