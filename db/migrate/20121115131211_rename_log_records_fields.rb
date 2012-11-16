class RenameLogRecordsFields < ActiveRecord::Migration

  def up
    rename_column :log_records, :doctype, :form
    rename_column :log_records, :voter_type, :form_type
    add_column    :log_records, :form_note, :string
    add_column    :log_records, :jurisdiction, :string
    remove_column :log_records, :notes
    add_column    :log_records, :notes, :string
  end

  def down
    remove_column :log_records, :notes
    add_column    :log_records, :notes, :text
    remove_column :log_records, :jurisdiction
    remove_column :log_records, :form_note
    rename_column :log_records, :form, :doctype
    rename_column :log_records, :form_type, :voter_type
  end

end
