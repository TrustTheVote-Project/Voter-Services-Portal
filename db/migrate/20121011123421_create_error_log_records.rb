class CreateErrorLogRecords < ActiveRecord::Migration
  def change
    create_table :error_log_records do |t|
      t.string  :message, null: false
      t.text    :details

      t.timestamps
    end
  end
end
