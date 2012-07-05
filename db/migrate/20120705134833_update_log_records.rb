class UpdateLogRecords < ActiveRecord::Migration
  def up
    remove_column :log_records, :subject
    add_column    :log_records, :voter_id, :string
    add_column    :log_records, :doctype,  :string
    rename_column :log_records, :details,  :notes
  end

  def down
    rename_column :log_records, :notes, :details
    remove_column :log_records, :doctype
    remove_column :voter_id
    add_column    :log_records, :subject, :string
  end
end
