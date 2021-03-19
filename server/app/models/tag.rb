class Tag < ApplicationRecord
  has_many :product_tags
  has_many :products, through: :product_tags
  belongs_to :tag, optional: true

  validates_presence_of :title
  validates_uniqueness_of :title

  scope :supertags, lambda {
    select_clause = Tag.column_names.map { |atr| "COALESCE(tag2.#{atr}, tag1.#{atr}) #{atr}" }

    select(select_clause.join(', ')).from('tags tag1')
                                    .joins('LEFT OUTER JOIN tags tag2 ON tag1.tag_id = tag2.id')
  }
end
