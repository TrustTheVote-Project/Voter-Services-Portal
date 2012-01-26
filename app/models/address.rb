class Address < ActiveRecord::Base

  attr_accessible :full_name, :street, :city, :state, :zip, :country

end
