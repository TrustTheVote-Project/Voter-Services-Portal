class RenameRegistrationRequestsToRegistrations < ActiveRecord::Migration
  def up
    rename_table :registration_requests, :registrations
  end

  def down
    rename_table :registrations, :registration_requests
  end
end
