class CreateQueuedVoterReports < ActiveRecord::Migration
  def change
    create_table :queued_voter_reports do |t|
      t.belongs_to :queued_voter, null: false
      t.string     :polling_location_id, null: false
      t.datetime   :arrived_at, null: false
      t.datetime   :cancelled_at
      t.datetime   :completed_at

      t.timestamps
    end

    add_index :queued_voter_reports, :queued_voter_id
  end
end
