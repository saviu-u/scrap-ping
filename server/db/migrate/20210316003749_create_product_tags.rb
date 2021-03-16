class CreateProductTags < ActiveRecord::Migration[6.1]
  def change
    create_table :product_tags do |t|
      t.references :product
      t.references :tag

      t.string :value

      t.timestamps
    end
  end
end
