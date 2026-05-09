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

ActiveRecord::Schema[8.1].define(version: 2026_05_02_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "payment_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "line_items"
    t.string "payment_intent_id"
    t.string "status"
    t.decimal "surcharge", precision: 10, scale: 2, default: "0.0", null: false
    t.string "token"
    t.decimal "total_amount_paid", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_payment_links_on_token", unique: true
  end
end
