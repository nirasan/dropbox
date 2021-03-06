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

ActiveRecord::Schema.define(version: 20150719014754) do

  create_table "event_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "event_logs", ["user_id"], name: "index_event_logs_on_user_id"

  create_table "nodes", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "name"
    t.integer  "parent_node_id"
    t.boolean  "is_folder"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "is_root"
    t.string   "file"
    t.string   "share_path"
    t.integer  "share_mode"
  end

  add_index "nodes", ["parent_node_id"], name: "index_nodes_on_parent_node_id"
  add_index "nodes", ["share_path"], name: "index_nodes_on_share_path", unique: true
  add_index "nodes", ["user_id"], name: "index_nodes_on_user_id"

  create_table "share_users", force: :cascade do |t|
    t.integer  "node_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "share_users", ["node_id"], name: "index_share_users_on_node_id"
  add_index "share_users", ["user_id"], name: "index_share_users_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
