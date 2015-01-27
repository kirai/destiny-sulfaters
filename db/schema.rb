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

ActiveRecord::Schema.define(version: 3) do

  create_table "characters", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.text     "character_hash", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clans", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "platform",       limit: 255
    t.string   "bungie_clan_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "clan_id",    limit: 4
    t.string   "email",      limit: 255
    t.string   "password",   limit: 255
    t.string   "token",      limit: 255
    t.string   "username",   limit: 255
    t.string   "platform",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
