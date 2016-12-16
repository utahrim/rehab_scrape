class CreateFacilities < ActiveRecord::Migration
  def change
    create_table :facilities do |t|
      t.string :name, null:false
      t.string :city
      t.string :state
      t.string :address
      t.string :zip
      t.string :county
      t.string :phone_number
      t.string :description
      t.string :classification
      t.string :year_built
      t.string :annual_rounds
      t.string :manager
      t.string :architect
      t.string :superintendent
      t.string :professional
      t.string :director_of_golf
      t.string :guest_policy
      t.string :dress_code
      t.string :website
      t.string :holes
      t.string :greens
      t.string :fairways
      t.string :water_hazards
      t.string :bunkers
      t.string :driving_range
      t.string :greens_fee_weekend
      t.string :greens_fee_weekdays
      t.timestamps null: false
    end
  end
end