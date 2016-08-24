class Facility < ActiveRecord::Base
  def self.to_csv
    attributes = %w{name state county city address zip_code phone}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |facility|
        csv << facility.attributes.values_at(*attributes)
      end
    end
  end
end
