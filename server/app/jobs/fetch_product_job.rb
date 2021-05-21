class FetchProductJob < ApplicationJob
  queue_as :default

  def perform(data, spider, id = nil)
    (Product.find_by(id: id) || Product.new).fetch_data(data, spider.new)&.save!
    sleep(rand(4..6))
  end

  def reschedule_at(current_time, attempts)
    current_time + attempts * rand(4..6).minutes
  end

  def max_attempts
    3
  end
end
