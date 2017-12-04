class Facility < ActiveRecord::Base
  def self.to_csv
    attributes = %w{facility_name facility_state facility_address facility_city facility_zip facility_phone_number facility_extra_info}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |facility|
        csv << facility.attributes.values_at(*attributes)
      end
    end
  end
end
