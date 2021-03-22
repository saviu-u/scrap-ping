class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :slug, index: true
      t.string :title
      t.string :ean
      t.string :image_path

      t.references :category

      t.timestamps
    end
  end
end
