class CreateActiveForms < ActiveRecord::Migration
  def change
    create_table :active_forms do |t|
      t.string :voter_id
      t.string :form, null: false
      t.string :jurisdiction
      t.timestamps
    end
  end
end
