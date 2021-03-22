class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :category
  has_many :prices
  has_many :shops, through: :prices

  has_many :product_tags, dependent: :delete_all
  # has_many :

  # accepts_nested_attributes_for :tags
  accepts_nested_attributes_for :product_tags, allow_destroy: true

  validates_presence_of :title, :ean, :category
  validates_uniqueness_of :ean
  # after_validation :retrieve_category

  def fetch_data(data, spider)
    # Set variables
    self.category = Category.find_or_create_by(title: data.delete(:category))
    id = data[:integration_id]

    # Retrieve more data
    data.merge!(spider.instance_hash(id)) if id.present?

    # Creating tags
    assigned_tags = product_tags.includes(:tag)
    tags = Tag.all
    data_tag = data.delete(:tags).map do |key, value|
      product_tag = assigned_tags.find { |pt| pt.tag.title == key }
      tag = tags.find { |model| model.title == key }
      {
        id: product_tag&.id, value: value,
        **(tag ? {tag: tag} : {tag_attributes: { id: tag&.id, title: key }})
      }
    end

    # Assigning existing attributes
    assign_attributes(data.slice(*attributes.keys.map(&:to_sym)))
    assign_attributes(product_tags_attributes: data_tag)

    self
  end
end
