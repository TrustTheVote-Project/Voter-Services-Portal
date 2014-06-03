class AddPollingLocationsToQueuedVoters < ActiveRecord::Migration
  def change
    add_column :queued_voters, :polling_locations, :text
  end
end
