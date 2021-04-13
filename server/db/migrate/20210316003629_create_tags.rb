class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string :slug, index: true
      t.string :title

      t.bigint :sub_tag_id, index: true

      t.timestamps
    end
  end
end
