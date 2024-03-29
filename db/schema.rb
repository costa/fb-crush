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

ActiveRecord::Schema.define(version: 20150221143506) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "friends", force: true do |t|
    t.integer  "ego_id"
    t.integer  "user_id"
    t.string   "intention"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "mutual_intention_since"
    t.datetime "different_intention_since"
    t.integer  "prev_crush_friend_id"
    t.integer  "next_crush_friend_id"
  end

  add_index "friends", ["ego_id", "user_id"], name: "index_friends_on_ego_id_and_user_id", unique: true, using: :btree
  add_index "friends", ["ego_id"], name: "index_friends_on_ego_id", using: :btree
  add_index "friends", ["next_crush_friend_id"], name: "index_friends_on_next_crush_friend_id", using: :btree
  add_index "friends", ["prev_crush_friend_id"], name: "index_friends_on_prev_crush_friend_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "friends_fetched_at"
    t.string   "access_token"
    t.datetime "last_login_at"
    t.string   "last_session_key"
  end

  add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, using: :btree

end
