class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :state,   default: 'VA'
      t.string :zip
      t.string :country, default: 'United States'
    end
  end
end
