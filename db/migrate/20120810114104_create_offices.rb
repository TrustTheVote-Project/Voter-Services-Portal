class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.string :locality, null: false
      t.string :address,  null: false
    end

    add_index :offices, :locality, unique: true
  end
end
