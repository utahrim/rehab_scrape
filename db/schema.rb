# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160606195103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "facilities", force: :cascade do |t|
    t.string   "name",                null: false
    t.string   "city"
    t.string   "state"
    t.string   "address"
    t.string   "zip"
    t.string   "county"
    t.string   "phone_number"
    t.string   "description"
    t.string   "classification"
    t.string   "year_built"
    t.string   "annual_rounds"
    t.string   "manager"
    t.string   "architect"
    t.string   "superintendent"
    t.string   "professional"
    t.string   "director_of_golf"
    t.string   "guest_policy"
    t.string   "dress_code"
    t.string   "website"
    t.string   "holes"
    t.string   "greens"
    t.string   "fairways"
    t.string   "water_hazards"
    t.string   "bunkers"
    t.string   "driving_range"
    t.string   "greens_fee_weekend"
    t.string   "greens_fee_weekdays"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

end
