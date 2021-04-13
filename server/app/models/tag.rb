class Tag < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  TAGS_BLACKLIST = %w[
    modelo numero-da-peca pecas-para-montagem numero-do-modelo ean codigo codigo-de-barras
    referencia-do-modelo conteudo-da-embalagem recursos-de-videos recursos-de-audio outras-conexoes
  ].freeze

  has_many :product_tags
  has_many :products, through: :product_tags
  has_many :product_tags
  belongs_to :sub_tag, optional: true, foreign_key: :sub_tag_id, class_name: 'Tag'

  validates_presence_of :title
  validates_uniqueness_of :title

  scope :supertags, lambda {
    select_clause = Tag.column_names.map { |atr| "COALESCE(tag2.#{atr}, tags.#{atr}) #{atr}" }

    select(select_clause.join(', ')).joins('LEFT OUTER JOIN tags tag2 ON tags.tag_id = tag2.id')
  }

  def to_search
    {
      label: title,
      id: slug
    }
  end

  def fixing_tags
    update_to_sub_tag(self)
  end

  def self.fixing_tags
    Tags.includes(:product_tags).map(&method(:update_to_sub_tag)).all?(true)
  end

  private

  def update_to_sub_tag(tag)
    tag.product_tags.update_all(tag_id: tag.sub_tag&.id) if tag.sub_tag
  end
end
