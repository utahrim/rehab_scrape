class Facility < ActiveRecord::Base
  def self.to_csv
    attributes = %w{agency_name facility_name facility_state per_min fifteen_mins compared_rate savings}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |facility|
        csv << facility.attributes.values_at(*attributes)
      end
    end
  end
end
