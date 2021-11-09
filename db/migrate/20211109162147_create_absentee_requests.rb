class CreateAbsenteeRequests < ActiveRecord::Migration
  def change
    create_table :absentee_requests do |t|
      t.text :data
      t.text :previous_data
      t.timestamps
    end
  end
end
