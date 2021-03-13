# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_13_000823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "slug"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_categories_on_slug"
  end

  create_table "prices", force: :cascade do |t|
    t.float "price"
    t.float "discount"
    t.string "id_integration"
    t.bigint "shop_id"
    t.bigint "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_prices_on_product_id"
    t.index ["shop_id"], name: "index_prices_on_shop_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "slug"
    t.string "title"
    t.string "ean"
    t.string "image_path"
    t.bigint "categories_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["categories_id"], name: "index_products_on_categories_id"
    t.index ["slug"], name: "index_products_on_slug"
  end

  create_table "shops", force: :cascade do |t|
    t.string "slug"
    t.string "title"
    t.string "image_path"
    t.string "spider_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_shops_on_slug"
  end

end
