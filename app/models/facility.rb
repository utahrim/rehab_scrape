class Facility < ActiveRecord::Base
  def self.to_csv
    attributes = %w{id facility_name facility_city facility_county facility_state facility_primary_focus facility_type_of_care facility_address facility_phone_number}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |facility|
        csv << facility.attributes.values_at(*attributes)
      end
    end
  end
end
