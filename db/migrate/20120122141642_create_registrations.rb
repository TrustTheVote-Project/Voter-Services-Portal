class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :voter_id
      t.string :first_name
      t.string :middle_name
      t.string :suffix_name_text
      t.string :last_name
      t.string :locality
      t.date   :dob
      t.string :ssn
      t.string :gender

      t.timestamps
    end
  end
end
