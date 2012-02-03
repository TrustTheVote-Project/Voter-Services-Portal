class AddFieldsToRegistrationRequests < ActiveRecord::Migration
  def change
    add_column :registration_requests, :outside_type, :string
    add_column :registration_requests, :outside_active_duty_details, :string
    add_column :registration_requests, :outside_spouse_active_duty_details, :string
  end
end
