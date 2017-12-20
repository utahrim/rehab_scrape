class Facility < ActiveRecord::Base
  def self.to_csv
    attributes = %w{facility_name facility_city facility_county facility_state facility_address}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |facility|
        csv << facility.attributes.values_at(*attributes)
      end
    end
  end
end
