class AddFlagsToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :absentee, :boolean
    add_column :registrations, :uocava, :boolean
  end
end
