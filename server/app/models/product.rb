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

  after_commit :search_shops

  def to_show
    best_price = prices.select(&:active).min_by(&:price)
    {
      id: slug,
      title: title,
      best_price: best_price&.price,
      best_price_shop: best_price&.shop&.to_show,
      best_price_link: best_price&.link
    }
  end

  def fetch_data(data, spider)
    # Set variables
    work_data = data.dup
    self.category = Category.find_or_create_by(title: work_data.delete(:category) || category&.title)

    # Retrieve more data
    work_data.merge!(spider.instance_hash(work_data[:id_integration])) if work_data[:id_integration] && !work_data[:ean]
    return unless work_data[:ean]

    work_data[:ean] = work_data[:ean]&.match(/\d+/).to_a[0]

    # Finding product
    if !id && existing = Product.find_by(ean: work_data[:ean])&.id
      FetchProductJob.perform_now(work_data, spider.class, existing)
      return nil
    end

    # Finding price
    price = prices.find_by(shop: spider.model) || Price.new

    return if price.persisted? && price.id_integration != work_data[:id_integration]

    price_attr = [
      {
        id: price.id,
        active: !work_data[:price].zero?,
        price: work_data.delete(:price),
        id_integration: work_data.delete(:id_integration),
        link: work_data.delete(:link),
        shop: spider.model
      }
    ]

    # Assigning existing attributes
    assign_attributes(work_data.slice(*empty_attrs))
    assign_attributes(product_tags_attributes: new_tag_attributes(work_data.delete(:tags)))
    assign_attributes(prices_attributes: price_attr)

    self
  rescue StandardError => e
    raise e unless e == 'TO_DESTROY'
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

  def search_shops
    Shop.where.not(id: prices.map(&:shop).map(&:id)).each do |shop|
      shop.spider.new(ean, category_title: category&.title).import
    end
  end

  private

  def empty_attrs
    attributes.reject { |_key, value| value.present? }.keys.map(&:to_sym)
  end
end
