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

ActiveRecord::Schema.define(:version => 20120203094213) do

  create_table "addresses", :force => true do |t|
    t.string "full_name"
    t.string "street"
    t.string "city"
    t.string "state",     :default => "VA"
    t.string "zip"
    t.string "country",   :default => "United States"
  end

  create_table "log_records", :force => true do |t|
    t.string   "subject"
    t.string   "action"
    t.text     "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "log_records", ["created_at"], :name => "index_log_records_on_created_at"

  create_table "registration_requests", :force => true do |t|
    t.string  "title"
    t.string  "first_name"
    t.string  "middle_name"
    t.string  "last_name"
    t.string  "suffix_name_text"
    t.date    "dob"
    t.boolean "citizen"
    t.boolean "old_enough"
    t.string  "voting_rights"
    t.string  "rights_revoke_reason"
    t.string  "rights_revoked_in_state"
    t.date    "rights_restored_on"
    t.string  "residence"
    t.string  "gender"
    t.string  "identify_by"
    t.string  "ssn"
    t.string  "dln_or_stateid"
    t.string  "phone"
    t.string  "email"
    t.integer "virginia_voting_address_id"
    t.integer "mailing_address_id"
    t.integer "foreign_state_address_id"
    t.boolean "authorized_cancelation"
    t.integer "non_us_residence_address_id"
    t.string  "outside_type"
    t.string  "outside_active_duty_details"
    t.string  "outside_spouse_active_duty_details"
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

end
