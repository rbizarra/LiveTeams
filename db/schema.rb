# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151203143935) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "geo_entities", force: :cascade do |t|
    t.string    "name",                                                                    null: false
    t.geography "latlon",      limit: {:srid=>4326, :type=>"geometry", :geographic=>true}, null: false
    t.integer   "user_id",                                                                 null: false
    t.text      "description"
    t.datetime  "created_at",                                                              null: false
    t.datetime  "updated_at",                                                              null: false
    t.string    "entity_type",                                                             null: false
    t.integer   "radius",                                                                  null: false
    t.integer   "team_id",                                                                 null: false
  end

  add_index "geo_entities", ["team_id"], name: "index_geo_entities_on_team_id", using: :btree
  add_index "geo_entities", ["user_id"], name: "index_geo_entities_on_user_id", using: :btree

  create_table "team_members", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.boolean  "is_leader"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "team_members", ["team_id"], name: "index_team_members_on_team_id", using: :btree
  add_index "team_members", ["user_id"], name: "index_team_members_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string    "name",                                                                      null: false
    t.geography "latlon_highlight", limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime  "created_at",                                                                null: false
    t.datetime  "updated_at",                                                                null: false
    t.integer   "location_user_id"
    t.geography "latlon",           limit: {:srid=>4326, :type=>"point", :geographic=>true}
  end

  add_index "teams", ["location_user_id"], name: "index_teams_on_location_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string    "email",                                                                           default: "", null: false
    t.string    "encrypted_password",                                                              default: "", null: false
    t.string    "reset_password_token"
    t.datetime  "reset_password_sent_at"
    t.datetime  "remember_created_at"
    t.integer   "sign_in_count",                                                                   default: 0,  null: false
    t.datetime  "current_sign_in_at"
    t.datetime  "last_sign_in_at"
    t.inet      "current_sign_in_ip"
    t.inet      "last_sign_in_ip"
    t.datetime  "created_at",                                                                                   null: false
    t.datetime  "updated_at",                                                                                   null: false
    t.string    "first_name",                                                                                   null: false
    t.string    "last_name",                                                                                    null: false
    t.string    "avatar_file_name"
    t.string    "avatar_content_type"
    t.integer   "avatar_file_size"
    t.datetime  "avatar_updated_at"
    t.string    "profile",                                                                                      null: false
    t.geography "latlon",                 limit: {:srid=>4326, :type=>"point", :geographic=>true},              null: false
    t.integer   "phone_number",                                                                                 null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "geo_entities", "teams"
  add_foreign_key "geo_entities", "users"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "teams", "users", column: "location_user_id"
end
