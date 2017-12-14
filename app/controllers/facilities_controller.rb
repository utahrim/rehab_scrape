class FacilitiesController < ApplicationController

  def index
  end

  def update
    facility = Facility.all
    facility.each do |fac|
      if fac.facility_county == "County:"
        f_city = fac.facility_city.split.map(&:capitalize).join(' ')
        if Location.where(city: "#{f_city}") != [] 
          f_county = Location.where(city: "#{f_city}").where(state: "#{fac.facility_state}")
          binding.pry
          fac.update_attributes(:facility_county, f_county.first.county)
          fac.save
          print"#{fac.name} updated #{fac.county}, #{fac.state}\n"
        end
      end
    end
  end

  def data
    @facilities = Facility.all
    respond_to do |format|
      format.html
      format.csv { send_data @facilities.to_csv, filename: "facilities-#{Date.today}.csv" }
    end
  end

  #  At the end do: get_pages("dc", "DC") 
  # {"AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas", "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware", "DC" => "District of Columbia", "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho", "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas", "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland", "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi", "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada", "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York", "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma", "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina", "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah", "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia", "WI" => "Wisconsin", "WY" => "Wyoming"}




  def search
    @driver = Selenium::WebDriver.for :chrome
    binding.pry
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    states_hash = {"CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware", "DC" => "District of Columbia", "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho", "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas", "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland", "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi", "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada", "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York", "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma", "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina", "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah", "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia", "WI" => "Wisconsin", "WY" => "Wyoming"}
    states_hash.each do |state_site|
    if state_site[0] == states_hash.first[0]
      @p = 1
    else
      @p = 1
    end
    @l = 0
      @driver.get ("https://www.seniorliving.org/facilities/#{state_site[0]}/")
      begin
        f_count = @driver.find_elements(:class, "gd-pagination-details").first.text.split(" ").last.to_i
        pages = f_count/10
        if pages%10 > 0
          pages += 1
        end
        until @p >= pages do
          @driver.get ("https://www.seniorliving.org/facilities/#{state_site[0]}/page/#{@p}")
          city_row_count = @wait.until {@driver.find_element(:id, "city_results").find_elements(:class, "head").count}
          until @l >= city_row_count do
            click_facility(state_site, @wait.until {@driver.find_element(:id, "city_results").find_elements(:class, "head")[@l]})
            @l += 1
          end
          @l = 0
          @p += 1
        end
        @p = 0
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        puts "Selenium::WebDriver::Error::StaleElementReferenceError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue NoMethodError
        puts "NoMethodError"
        sleep(3)
        rescue_error(state_site)
        retry
      rescue Net::ReadTimeout
        puts "Net::ReadTimeout"
        sleep(20)
        binding.pry
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::TimeOutError
        puts "Selenium::WebDriver::Error::TimeOutError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::UnknownError
        puts "Selenium::WebDriver::Error::UnknownError"
        sleep(1)
        rescue_error(state_site)
        retry
      end
    end
  end

  # def click_city(state_site, city)
  #   @driver.get(city.attribute("href"))
  #   sleep(2)
  #   facility_count = @wait.until {@driver.find_elements(:xpath, "//*[@id='city-results-list-block']/div").count}
  #   until @f >= facility_count do
  #     facility = @wait.until {@driver.find_elements(:xpath, "//*[@id='city-results-list-block']/div")[@f]}
  #     click_facility(state_site, facility)
  #     @f +=1
  #   end
  #   @f=0
  #   @driver.navigate.back
  # end

  def click_facility(state_site, facility)
    f_link = facility.find_element(:css, "a")
    @driver.get(f_link.attribute("href"))
    get_info(state_site)
  end

  def get_info(state_site)
    info_scrape(state_site, @driver.find_element(:class, "facility").find_elements(:css, "h5"))
  end

  def info_scrape(state_site, info)
    name = info.first.text.split("\n").last
    address = info[1].text.split("\n").last
    loc_arr = location(info[2].text.split("\n").last)
    city = loc_arr[0]
    state = state_site[1]
    zip = loc_arr[1]
    county = get_county(info)
    phone = get_phone(info)
    fax = get_fax(info)
    create_facility(name, city, county, state, address, zip, phone, fax)
  end

  # def info_scrape1(state_site, info)
  #   name = info.first.text.split("\n").last
  #   address = info[1].text.split("\n").last
  #   loc_arr = location(info[2].text.split("\n").last)
  #   city = loc_arr[0]
  #   state = state_site[1]
  #   zip = loc_arr[1]
  #   county = get_county(info)
  #   phone = get_phone(info)
  #   fax = ""
  #   create_facility(name, city, county, state, address, zip, phone, fax)
  # end

  def get_county(info)
    if info[3].text.split("\n").first == "County:"
      return info[3].text.split("\n").last
    elsif info[4].text.split("\n").first == "County:"
      return info[4].text.split("\n").last
    elsif info[-2].text.split("\n").first == "County:"
      return info[-2].text.split("\n").last
    else
      binding.pry
    end
  end

  def get_phone(info)
    if info[-2].text.split("\n").first == "Phone:"
      phone = info[-2].text.split("\n").last
    elsif info[-1].text.split("\n").first == "Phone:"
      phone = info[-1].text.split("\n").last
    elsif info[-3].text.split("\n").first == "Phone:"
      phone = info[-3].text.split("\n").last
    elsif info[4].text.split("\n").first == "Phone:"
      phone = info[4].text.split("\n").last
    elsif info[5].text.split("\n").first == "Phone:"
      phone = info[5].text.split("\n").last
    else
      phone = ""
    end
      return phone.gsub("(", "").gsub(") ", "-")
  end

  def get_fax(info)
    if info[-1].text.split("\n").first == "FAX:"
      fax = info[-1].text.split("\n").last
    elsif info[-2].text.split("\n").first == "FAX:"
      fax = info[-2].text.split("\n").last
    elsif info[-3].text.split("\n").first == "FAX:"
      fax = info[-3].text.split("\n").last
    elsif info[4].text.split("\n").first == "FAX:"
      fax = info[4].text.split("\n").last
    else
      fax = ""
    end
      return fax.gsub("(", "").gsub(")", "-").gsub(" ", "").gsub(".", "-")
  end


  def location(location)
    city = location.split(",").first
    state_zip = location.split(", ").last
    zip = state_zip.split(" ").last
    return [city, zip]
  end

  def create_facility(name, city, county, state, address, zip, phone, fax)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_county: county, facility_address: address, facility_zip: zip, facility_phone_number: phone, facility_fax: fax)
    @driver.navigate.back()
  end

  def rescue_error(state_site)
    binding.pry
    @driver.get ("https://www.seniorliving.org/facilities/#{state_site[0]}/page/#{@p}")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  end

end