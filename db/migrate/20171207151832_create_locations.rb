class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
    	t.string :city
    	t.string :county
    	t.string :state
      t.timestamps null: false
    end
  end
end
