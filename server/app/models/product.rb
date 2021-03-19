class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :category
  has_many :prices
  has_many :shops, through: :prices

  has_many :product_tags
  # has_many :

  accepts_nested_attributes_for :tags
  accepts_nested_attributes_for :product_tags

  before_validation :fetch_data

  validates_presence_of :title, :ean, :category

  after_validation :retrieve_category

  def fetch_data(data, spider)
    # Set variables
    self.category = Category.find_or_create_by(title: data.slice(:category))
    id = data[:id_integration]

    # Retrieve more data
    data.merge!(spider.instance_hash(id)) if id.present?

    # Assigning existing attributes
    assign_attributes(data.slice(*attributes.keys.map(&:to_sym)))

    # Creating tags
    assigned_tags = product_tags.includes(:tag)
    data_tag = data.delete(:tags).map do |key, value|
      product_tag = assigned_tags.find { |pt| pt.tag.title == key }
      {
        id: product_tag&.id,
        value: value,
        tag_attribute: {
          id: product_tag&.tag&.id,
          title: key
        }
      }
    end
  end
end
