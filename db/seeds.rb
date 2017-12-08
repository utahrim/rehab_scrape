# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'Home-Health-Care(21156).csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |row|
  f = Facility.new
  f.facility_name = row['facility_name']
  f.facility_state = row['facility_state']
  f.facility_address = row['facility_address']
  f.facility_city = row['facility_city']
  f.facility_zip = row['facility_zip']
  f.facility_phone_number = row['facility_phone_number']
  f.facility_extra_info = row['facility_extra_info']
  f.save
  puts "#{f.facility_address}, #{f.facility_city} saved"
end

puts "There are now #{Facility.count} rows in the transactions table"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'locations_Final.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |row|
  l = Location.new
  l.city = row['city']
  l.county = row['county']
  l.state = row['state']
  l.save
  puts "#{l.city}, #{l.county}, #{l.state} saved"
end
