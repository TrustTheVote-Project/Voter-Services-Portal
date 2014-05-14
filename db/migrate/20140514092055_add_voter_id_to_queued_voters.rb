class AddVoterIdToQueuedVoters < ActiveRecord::Migration
  def change
    add_column :queued_voters, :voter_id, :string
    add_index  :queued_voters, :voter_id, unique: true
  end
end
