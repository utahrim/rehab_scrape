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
    @user_agent = "Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10;"
    @driver = Selenium::WebDriver.for :chrome, :switches => %W[--user-agent="#{@user_agent}"]
    binding.pry
    states_hash = {"AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas", "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware", "DC" => "District of Columbia", "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho", "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas", "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland", "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi", "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada", "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York", "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma", "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina", "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah", "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia", "WI" => "Wisconsin", "WY" => "Wyoming"}
    @c = 0
    @f = 0
    @l = 0
    states_hash.each do |state_site|
      alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
      alphabet.each do |letter|
        @driver.get ("https://accounts.ncic.com/#{state_site[0]}/#{letter}/addfundsfac")
        @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
        
        county_col_count = @wait.until {@driver.find_elements(:xpath, "//*[@id='aspnetForm']/div[3]/div[10]/div/div/div/div/div/div[2]/div/div").count}
        until @c >= county_col_count do 
          county_col = @wait.until {@driver.find_elements(:xpath, "//*[@id='aspnetForm']/div[3]/div[10]/div/div/div/div/div/div[2]/div/div")[@c]}
          count_list(state_site, county_col)
          @c += 1

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
  end

  def count_list(state_site, col)
    list_count = col.find_elements(:css, "a").count
    until @f <= list_count do
      facility = @wait.until {@driver.find_elements(:xpath, "//*[@id='aspnetForm']/div[3]/div[10]/div/div/div/div/div/div[2]/div/div")[@c].find_elements(:css, "a")[@f]
      @driver.get(facility.attribute("href"))
      check_facility(state_site)
      @f+= 1
    end
  end

  def check_facility(state_site)
    @wait.until {@driver.find_element(:xpath, "//*[@id='aspnetForm']/div[3]/div[3]/div/div/div")}
    sleep(3)
    if @driver.find_element(:xpath, "//*[@id='ctl00_ContentPlaceHolder1_lblInmate']").text == "Select Inmate (Last Name)"
      get_letters(state_site)
    else
      @f +=1 
    end
  end 

  def get_letters(state_site)
    letter_arr = [0, 5, 10, 15, 20, 25]
    letter_arr.each do |let| 
      @driver.find_elements(:xpath, "//*[@id='ddlAlph_DDD_L_divAlpha#{let}_0']")
    end
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