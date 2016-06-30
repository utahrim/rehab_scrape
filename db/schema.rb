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
    t.string   "facility_name",           null: false
    t.string   "facility_city",           null: false
    t.string   "facility_county",         null: false
    t.string   "facility_state",          null: false
    t.string   "facility_primary_focus"
    t.string   "facility_type_of_care"
    t.string   "facility_address",        null: false
    t.string   "facility_phone_number"
    t.string   "facility_hotline_number"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
