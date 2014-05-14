class CreateQueuedVoters < ActiveRecord::Migration
  def change
    create_table :queued_voters do |t|
      t.string :token, null: false

      t.timestamps
    end

    add_index :queued_voters, :token, unique: true
  end
end
