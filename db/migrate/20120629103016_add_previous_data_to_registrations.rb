class AddPreviousDataToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :previous_data, :text

  end
end
