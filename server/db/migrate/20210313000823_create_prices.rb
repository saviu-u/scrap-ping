class CreatePrices < ActiveRecord::Migration[6.1]
  def change
    create_table :prices do |t|
      t.float :price
      t.float :discount

      t.string :id_integration

      t.references :shop
      t.references :product

      t.timestamps
    end
  end
end
