# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Shop creations
existing_shops = Shop.pluck(:spider_name).map { |class_name| class_name.demodulize.to_sym }
(Spider.constants - existing_shops).each do |spider|
  next if (spider = "Spider::#{spider}".constantize) >= Spider::SpiderBase

  Shop.create!(title: spider.to_s.demodulize, spider_name: spider.to_s, image_path: 'undefined')
end

if Delayed::Job.count.zero?
  %w[tv notebook microondas].each do |product|
    Shop.all.each { |shop| shop.spider.new(product).import }
  end
end

# last_price = Price.all.min(&:updated_at)
# if last_price.nil? || ((last_price.updated_at + 30.minutes) > Time.zone.now)
  
# end