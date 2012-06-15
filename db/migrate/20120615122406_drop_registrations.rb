class DropRegistrations < ActiveRecord::Migration
  def up
    drop_table :registrations
  end

  def down
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
end
