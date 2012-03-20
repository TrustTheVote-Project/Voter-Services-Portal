class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :name, null: false
      t.string :value
    end

    add_index :settings, :name, :unique => true
  end
end
