class CreateFacilities < ActiveRecord::Migration
  def change
    create_table :facilities do |t|
      t.string :facility_name, null:false
      t.string :facility_city, null:false
      t.string :facility_county
      t.string :facility_zip
      t.string :facility_state, null:false
      t.string :facility_primary_focus
      t.string :facility_type_of_care
      t.string :facility_address, null:false
      t.string :facility_phone_number
      t.string :facility_extra_info
      t.timestamps null: false
    end
  end
end
