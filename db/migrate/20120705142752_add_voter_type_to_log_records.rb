class AddVoterTypeToLogRecords < ActiveRecord::Migration
  def change
    add_column :log_records, :voter_type, :string

  end
end
