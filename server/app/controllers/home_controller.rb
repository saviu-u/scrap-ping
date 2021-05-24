class HomeController < ApplicationController
  def index
    render_json(
      {
        products: products,
        categories: categories,
        shops: shops,
        jobs_running: jobs_hash
      }
    )
  end

  private

  def products
    Category.includes(products: [:category, prices: :shop]).limit(3).map do |category|
      { category.title => category.retrieve_products }
    end
  end

  def categories
    Category.all.map(&:to_index)
  end

  def shops
    Shop.all.map(&:to_index)
  end

  def jobs_hash
    active = total = errors = 0

    Delayed::Job.all.each do |dj|
      active += 1 if dj.locked_at
      errors += 1 if dj.last_error
      total += 1
    end

    { active: active, errors: errors, total: total }
  end
end