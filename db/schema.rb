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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120320103006) do

  create_table "log_records", :force => true do |t|
    t.string   "subject"
    t.string   "action"
    t.text     "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "log_records", ["created_at"], :name => "index_log_records_on_created_at"

  create_table "registration_requests", :force => true do |t|
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "registrations", :force => true do |t|
    t.string   "voter_id"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "suffix_name_text"
    t.string   "last_name"
    t.string   "locality"
    t.date     "dob"
    t.string   "gender"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "phone"
    t.string   "email"
    t.string   "party_affiliation"
    t.string   "voting_address"
    t.string   "mailing_address"
    t.boolean  "absentee"
    t.boolean  "uocava"
  end

  create_table "settings", :force => true do |t|
    t.string "name",  :null => false
    t.string "value"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name", :unique => true

end
