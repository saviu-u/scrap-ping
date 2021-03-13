class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :slug, index: true
      t.string :title

      t.timestamps
    end
  end
end
