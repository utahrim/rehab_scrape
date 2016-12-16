class Facility < ActiveRecord::Base
  def self.to_csv
    attributes = %w{name city state address zip county phone_number description classification year_built annual_rounds manager architect superintendent professional director_of_golf website holes greens greens_fee_weekdays}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |facility|
        csv << facility.attributes.values_at(*attributes)
      end
    end
  end
end
