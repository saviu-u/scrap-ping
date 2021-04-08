class CreateShops < ActiveRecord::Migration[6.1]
  def change
    create_table :shops do |t|
      t.string :slug, index: true
      t.string :title
      t.string :image_path
      t.string :spider_name
      t.string :link

      t.timestamps
    end
  end
end
