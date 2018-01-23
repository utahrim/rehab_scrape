class CreateFacilities < ActiveRecord::Migration
  def change
    create_table :facilities do |t|
      t.string :agency_name
      t.string :facility_name
      t.string :facility_state
      t.string :initial_amount
      t.string :per_min
      t.string :fifteen_mins
      t.string :total
      t.string :compared_rate
      t.string :savings
      t.timestamps null: false
    end
  end
end
