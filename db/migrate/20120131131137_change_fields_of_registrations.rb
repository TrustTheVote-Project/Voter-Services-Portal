class ChangeFieldsOfRegistrations < ActiveRecord::Migration
  def up
    add_column    :registrations, :phone, :string
    add_column    :registrations, :email, :string
    add_column    :registrations, :party_affiliation, :string
    add_column    :registrations, :voting_address, :string
    add_column    :registrations, :mailing_address, :string
    remove_column :registrations, :ssn
  end

  def down
    add_column    :registrations, :ssn, :string
    remove_column :registrations, :phone
    remove_column :registrations, :email
    remove_column :registrations, :party_affiliation
    remove_column :registrations, :voting_address
    remove_column :registrations, :mailing_address
  end
end
