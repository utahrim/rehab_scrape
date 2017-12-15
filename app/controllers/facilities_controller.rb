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
    binding.pry #Download vpn
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    states_hash = {"AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas", "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware", "DC" => "District of Columbia", "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho", "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas", "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland", "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi", "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada", "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York", "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma", "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina", "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah", "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia", "WI" => "Wisconsin", "WY" => "Wyoming"}
    @c = 0
    @f = 0
    @l = 0
    @i = 0
    @lc = 0
    states_hash.each do |state_site|
      alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
      alphabet.each do |letter|
        @driver.get ("https://accounts.ncic.com/#{state_site[0]}/#{letter}/addfundsfac")
        if @driver.find_elements(:xpath, "//*[@id='ctl00_ContentPlaceHolder1_lblNoFac']") == []
        begin
          county_col_count = @wait.until {@driver.find_elements(:xpath, "//*[@id='aspnetForm']/div[3]/div[10]/div/div/div/div/div/div[2]/div/div").count}
          until @c >= county_col_count do 
            county_col = @wait.until {@driver.find_elements(:xpath, "//*[@id='aspnetForm']/div[3]/div[10]/div/div/div/div/div/div[2]/div/div")[@c]}
            count_list(state_site, county_col)
            @c += 1
          end
          @c = 0

          rescue Selenium::WebDriver::Error::StaleElementReferenceError
            puts "Selenium::WebDriver::Error::StaleElementReferenceError"
            sleep(1)
            rescue_error(state_site, letter)
            retry
          rescue NoMethodError
            puts "NoMethodError"
            @check_error += 1
            sleep(3)
            rescue_error(state_site, letter)
            retry
          rescue Net::ReadTimeout
            puts "Net::ReadTimeout"
            sleep(20)
            @driver.navigate.refresh()
            rescue_error(state_site, letter)
            retry
          rescue Selenium::WebDriver::Error::TimeOutError
            puts "Selenium::WebDriver::Error::TimeOutError"
            sleep(1)
            rescue_error(state_site, letter)
            retry
          rescue Selenium::WebDriver::Error::UnknownError
            puts "Selenium::WebDriver::Error::UnknownError"
            sleep(1)
            rescue_error(state_site, letter)
            retry
          end
        end
      end
    end
  end

  def count_list(state_site, col)
    list_count = col.find_elements(:css, "a").count
    until @f >= list_count do
      facility = @wait.until {@driver.find_elements(:xpath, "//*[@id='aspnetForm']/div[3]/div[10]/div/div/div/div/div/div[2]/div/div")[@c].find_elements(:css, "a")[@f]}
      @driver.get(facility.attribute("href"))
      check_facility(state_site)
      @f += 1
    end
    @f = 0
  end

  def check_facility(state_site)
    @wait.until {@driver.find_element(:xpath, "//*[@id='aspnetForm']/div[3]/div[3]/div/div/div")}
    sleep(3)
    facility_n = @driver.find_element(:id, "ctl00_lblFacility").text
    if @driver.find_elements(:xpath, "//*[@id='ctl00_ContentPlaceHolder1_lblInmate']") !=[]
      get_letters(state_site, facility_n) 
    end
    sleep(3)
    @driver.navigate.back()
  end 

  def get_letters(state_site, facility_n)
    # [0, 5, 10, 15, 20, 25]
    letter_arr = [20, 25]
    letter_arr.each do |let| 
      if @driver.find_elements(:xpath, "//*[@id='ddlAlph_DDD_L_divAlpha#{let}_0']") != []
          letter_row = @driver.find_element(:xpath, "//*[@id='ddlAlph_DDD_L_divAlpha#{let}_0']")
          letter_count = letter_row.find_elements(:class, "rTableCell").count
        until @lc >= letter_count do
          letter_row = @wait.until {@driver.find_element(:xpath, "//*[@id='ddlAlph_DDD_L_divAlpha#{let}_0']")}
          sleep(5)
          letter_row.find_elements(:class, "rTableCell")[@lc].click
          get_inmate(state_site, facility_n)
          @lc += 1
        end
        @lc = 0
      else 
        rescue_error(state_site, letter)
      end
    end
  end

  def get_inmate(state_site, facility_n)
    until @wait.until {@driver.find_elements(:id, "ctl00_ContentPlaceHolder1_btnInmatePay#{@i}")} == [] do
      info = @driver.find_element(:id, "ctl00_ContentPlaceHolder1_btnInmatePay#{@i}").text
      name_arr = info.split("\n").first.split(", ")
      name = name_arr.last
      city = name_arr.first
      address = facility_n
      state = state_site[1]
      create_facility(name, city, state, address)
      @i += 1
    end
    @i = 0
    @driver.navigate.back()
  end

  #name = first name
  #city = last name
  #address = prison name

  def create_facility(name, city, state, address)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_address: address)
  end

  def rescue_error(state_site, letter)
    @driver = Selenium::WebDriver.for :chrome
    binding.pry #VPN
    @driver.get ("https://accounts.ncic.com/#{state_site[0]}/#{letter}/addfundsfac")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    # @l += 1
  end
end