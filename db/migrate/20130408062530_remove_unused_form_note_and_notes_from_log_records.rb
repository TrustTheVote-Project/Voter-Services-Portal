class RemoveUnusedFormNoteAndNotesFromLogRecords < ActiveRecord::Migration
  def up
    remove_column :log_records, :form_note
    remove_column :log_records, :notes
  end

  def down
    add_column :log_records, :form_note, :string
    add_column :log_records, :notes, :string
  end
end
