class CreateRegistrationRequests < ActiveRecord::Migration
  def change
    create_table :registration_requests do |t|
      t.string  :title
      t.string  :first_name
      t.string  :middle_name
      t.string  :last_name
      t.string  :suffix_name_text
      t.date    :dob
      t.boolean :citizen
      t.boolean :old_enough
      t.boolean :was_convicted
      t.string  :conviction_state
      t.date    :rights_restored_on
      t.string  :residence
      t.string  :gender
      t.string  :identify_by
      t.string  :dln_or_ssn
      t.string  :phone
      t.string  :email

      t.integer :virginia_voting_address_id
      t.integer :mailing_address_id
      t.integer :foreign_state_address_id
      t.boolean :authorized_cancelation
      t.integer :non_us_residence_address_id
    end
  end
end
