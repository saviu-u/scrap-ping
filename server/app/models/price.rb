class Price < ApplicationRecord
  belongs_to :shop, :product
end
