class CreateQueuedVoterReports < ActiveRecord::Migration
  def change
    create_table :queued_voter_reports do |t|
      t.belongs_to :queued_voter, null: false
      t.string     :polling_location_id, null: false
      t.datetime   :arrived_on, null: false
      t.datetime   :cancelled_on
      t.datetime   :completed_on

      t.timestamps
    end

    add_index :queued_voter_reports, :queued_voter_id
  end
end
