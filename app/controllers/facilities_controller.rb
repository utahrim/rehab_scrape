class FacilitiesController < ApplicationController

  def index
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
    states_hash = {"AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas", "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware", "DC" => "District of Columbia", "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho", "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas", "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland", "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi", "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada", "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York", "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma", "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina", "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah", "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia", "WI" => "Wisconsin", "WY" => "Wyoming"}

    states_hash.each do |state_site|
      @driver.get ("https://www.homehealthcareagencies.com/directory/#{state_site[0]}/")
      @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
      if state_site[0] == states_hash.first.first
        @c = 0
        @cl = 0
      else
        @c = 0
        @cl = 0
      end
      @l = 1
      @check_error = 0
      begin
        city_list_row_count = @wait.until{@driver.find_elements(:class, "col-sm-4").count}
        until @cl >= city_list_row_count do
          city_list_count = @wait.until {@driver.find_elements(:class, "col-sm-4")[@cl].find_elements(:css, "a").count}
          until @c >= city_list_count
            city_list = @driver.find_elements(:class, "col-sm-4")[@cl].find_elements(:css, "a")
            get_city(state_site, city_list[@c])
            @c += 1
            @check_error = 0
          end
          @c = 0
          @cl += 1
        end
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        puts "Selenium::WebDriver::Error::StaleElementReferenceError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue NoMethodError
        puts "NoMethodError"
        @check_error += 1
        if @check_error >= 2
          binding.pry
        end
        sleep(3)
        rescue_error(state_site)
        retry
      rescue Net::ReadTimeout
        puts "Net::ReadTimeout"
        sleep(20)
        @driver.navigate.refresh()
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::TimeOutError
        puts "Selenium::WebDriver::Error::TimeOutError"
        sleep(1)
        if @driver.current_url.split("-")[1] == "touch"
          @driver.navigate.back()
        end
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::UnknownError
        puts "Selenium::WebDriver::Error::UnknownError"
        if @check_error == 0 || @check_error != @l
          @check_error = @l
        elsif @check_error == @l
          @l +=1
        end 
        sleep(1)
        rescue_error(state_site)
        retry
      end
    end
  end

  def get_city(state_site, city)
    sleep(0.3)
    @driver.get(city.attribute("href"))
    city_facility(state_site)
  end

  def city_facility(state_site)
    facility_list_count = @wait.until {@driver.find_element(:class, "striped-rows").find_elements(:class, "row").count}
    until @l >= facility_list_count do
      facility_list = @wait.until {@driver.find_element(:class, "striped-rows").find_elements(:class, "row")[@l]}
      if facility_list.text.split("\n").last == "Click to Show Phone"
        binding.pry
      end
      facility_list = @wait.until {@driver.find_element(:class, "striped-rows").find_elements(:class, "row")[@l].find_elements(:css, "div")}
      get_info(state_site, facility_list)
    end
    @l = 1
  end

  def get_info(state_site, facility)
    if facility.count <= 1
      @l += 1
    else
      info_check(state_site, facility)
      @l += 1
    end
  end

  def info_check(state_site, info_array)
    name = get_name(info_array[0].text)
    add_info = get_address(info_array[1].text)
    address = add_info[0]
    phone = get_phone(info_array)
    city = add_info[1]
    state = state_site[1]
    zip = add_info[2]
    if info_array.count >= 4
      extra_info = info_array.last.text
    else
      extra_info = ""
    end
    create_facility(name, city, state, address, zip, phone, extra_info)
  end

  def get_name(name_string)
    if name_string.include?("\n")
      return name_string.split("\n")[0]
    else
      return name_string
    end
  end

  def get_phone(info_array)
    phone_array = info_array[2].find_elements(:class, "phone")
    if phone_array.count >= 4
      phone = phone_array[2].text
    else
       if phone_array.last.text == ""
        phone = phone_array.first.text
      else
        phone = phone_array.last.text
      end
    end
    return phone.gsub("(", "").gsub(") ", "-")
  end

  def get_address(address_array)
    if address_array.include?("\n")
      add_arr = address_array.split("\n")
      address = add_arr[0]
      add = add_arr[1].split(", ")
    else
      add = address_array.split(", ")
      address = ""
    end
      city = add[0]
      zip = add[1].split(" ")[1]
    return [address, city, zip]
  end

  def create_facility(name, city, state, address, zip, phone, extra_info)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_address: address, facility_zip: zip, facility_phone_number: phone, facility_extra_info: extra_info)
  end

  def rescue_error(state_site)
    @driver.get ("https://www.homehealthcareagencies.com/directory/#{state_site[0]}/")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    # @l += 1
  end

end