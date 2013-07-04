class DeleteBedfordCityOffice < ActiveRecord::Migration
  def up
    Office.delete_all(locality: "BEDFORD CITY")
  end
end
