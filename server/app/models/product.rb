class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :category
  has_many :prices, dependent: :delete_all
  has_many :shops, through: :prices

  has_many :product_tags, dependent: :delete_all
  has_many :fixed_tags, -> { supertags }, class_name: 'Tag', through: :product_tags, source: :tag

  # accepts_nested_attributes_for :tags
  accepts_nested_attributes_for :product_tags, allow_destroy: true
  accepts_nested_attributes_for :prices, allow_destroy: true

  validates_presence_of :title, :ean, :category
  validates_uniqueness_of :ean
  # after_validation :retrieve_category

  def fetch_data(data, spider)
    # Set variables
    work_data = data.dup
    self.category = Category.find_or_create_by(title: work_data.delete(:category) || category&.title)
    (show_id = {})[:id] = work_data[:integration_id]

    # Retrieve more data
    work_data.merge!(spider.instance_hash(show_id[:id])) if show_id[:id] && !show_id[:ean]

    # Finding product
    show_id[:ean] = work_data[:ean].match(/\d+/).to_a[0]
    if !id && (existing = Product.find_by(ean: show_id[:ean])&.id)
      FetchProductJob.perform_now(work_data, spider.class, existing)
      return nil
    end

    # Finding price
    price = prices.find_by(id_integration: work_data[:id_integration]) || Price.new
    price_attr = [
      {
        id: price.id,
        price: work_data.delete(:price),
        id_integration: work_data.delete(:id_integration),
        shop: spider.model
      }
    ]

    # Assigning existing attributes
    assign_attributes(work_data.slice(*empty_attrs))
    assign_attributes(product_tags_attributes: new_tag_attributes(work_data.delete(:tags)))
    assign_attributes(prices_attributes: price_attr)

    self
  end

  def new_tag_attributes(data)
    assigned_tags = product_tags.includes(:tag)
    tags = Tag.includes(:sub_tag)

    data.map do |key, value|
      key = key.capitalize

      product_tag = assigned_tags.find { |pt| pt.tag.title == key }

      tag = tags.find { |model| model.title == key }
      tag = tag&.sub_tag || tag

      {
        id: product_tag&.id, value: value,
        **(tag ? { tag: tag } : { tag_attributes: { id: tag&.id, title: key } })
      }
    end
  end

  def price_update
    Shop.all.each { |shop| shop.spider.new(ean, category_title: category&.title).import }
  end

  private

  def empty_attrs
    attributes.reject { |_key, value| value.present? }.keys.map(&:to_sym)
  end
end
