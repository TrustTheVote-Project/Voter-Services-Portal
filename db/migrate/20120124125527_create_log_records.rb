class CreateLogRecords < ActiveRecord::Migration
  def change
    create_table :log_records do |t|
      t.string  :subject
      t.string  :action
      t.text    :details

      t.timestamps
    end

    add_index :log_records, :created_at
  end
end
