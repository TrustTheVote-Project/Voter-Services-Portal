class AddFieldsToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :city, :string
    add_column :offices, :state, :string
    add_column :offices, :zip, :string
    add_column :offices, :phone, :string
    rename_column :offices, :address, :addressline
  end
end
