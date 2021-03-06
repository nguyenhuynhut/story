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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110610061104) do

  create_table "airdates", :force => true do |t|
    t.datetime "airdate"
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "characters", :force => true do |t|
    t.string   "salutation"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "phone_3"
    t.string   "email_1"
    t.string   "email_2"
    t.text     "notes"
    t.string   "avatar"
    t.string   "rep_phone"
    t.string   "rep_email"
    t.string   "representative"
    t.string   "rep_address"
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shoots", :force => true do |t|
    t.date     "date"
    t.text     "crew_requirements"
    t.text     "location"
    t.boolean  "senior_approval"
    t.boolean  "assigned"
    t.text     "notes"
    t.text     "preshow_tease"
    t.boolean  "check_mail"
    t.string   "name"
    t.integer  "cameraperson_id"
    t.integer  "approver_id"
    t.integer  "story_id"
    t.integer  "staff_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffs", :force => true do |t|
    t.string   "userid"
    t.string   "password"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "title"
    t.string   "avatar"
    t.string   "phone"
    t.string   "token"
    t.boolean  "is_senior_producer"
    t.boolean  "is_assignment_editor"
    t.boolean  "is_producer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stories", :force => true do |t|
    t.string   "name"
    t.text     "outline"
    t.text     "graphics_collateral"
    t.string   "script"
    t.date     "deadline"
    t.string   "video"
    t.string   "fork_id"
    t.boolean  "check_mail"
    t.boolean  "approved"
    t.boolean  "archived"
    t.integer  "producer_id"
    t.integer  "correspondent_id"
    t.integer  "staff_id"
    t.integer  "editor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "webextras", :force => true do |t|
    t.string   "title"
    t.string   "name"
    t.text     "summary"
    t.boolean  "check_mail"
    t.string   "videourl"
    t.integer  "story_id"
    t.integer  "staff_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
