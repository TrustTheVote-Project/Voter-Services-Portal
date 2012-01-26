class Address < ActiveRecord::Base

  attr_accessible :address, :city, :state, :zip, :country

end
