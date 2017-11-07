class Facility < ActiveRecord::Base
  def self.to_csv
    attributes = %w{facility_name facility_state initial_amount per_min fifteen_mins total compared_rate savings}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |facility|
        csv << facility.attributes.values_at(*attributes)
      end
    end
  end
end
