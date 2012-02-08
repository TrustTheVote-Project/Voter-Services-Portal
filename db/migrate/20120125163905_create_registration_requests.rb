class CreateRegistrationRequests < ActiveRecord::Migration
  def change
    create_table :registration_requests do |t|
      t.text    :data
      t.timestamps
    end
  end
end
