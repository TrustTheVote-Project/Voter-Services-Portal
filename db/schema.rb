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

ActiveRecord::Schema.define(:version => 20140513080648) do

  create_table "active_forms", :force => true do |t|
    t.string   "voter_id"
    t.string   "form",         :null => false
    t.string   "jurisdiction"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "error_log_records", :force => true do |t|
    t.string   "message",    :null => false
    t.text     "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "log_records", :force => true do |t|
    t.string   "action"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "voter_id"
    t.string   "form"
    t.string   "form_type"
    t.string   "jurisdiction"
  end

  add_index "log_records", ["created_at"], :name => "index_log_records_on_created_at"

  create_table "offices", :force => true do |t|
    t.string "locality",    :null => false
    t.string "addressline", :null => false
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
  end

  add_index "offices", ["locality"], :name => "index_offices_on_locality", :unique => true

  create_table "queued_voter_reports", :force => true do |t|
    t.integer  "queued_voter_id",     :null => false
    t.string   "polling_location_id", :null => false
    t.datetime "arrived_on",          :null => false
    t.datetime "cancelled_on"
    t.datetime "completed_on"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "queued_voter_reports", ["queued_voter_id"], :name => "index_queued_voter_reports_on_queued_voter_id"

  create_table "queued_voters", :force => true do |t|
    t.string   "token",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "queued_voters", ["token"], :name => "index_queued_voters_on_token", :unique => true

  create_table "registrations", :force => true do |t|
    t.text     "data"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "previous_data"
  end

  create_table "settings", :force => true do |t|
    t.string "name",  :null => false
    t.string "value"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name", :unique => true

end
