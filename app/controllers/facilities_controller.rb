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

  def search
  states = ["alaska", "alabama", "arkansas", "arizona", "california", "colorado", "connecticut", "delaware", "florida", "georgia", "hawaii", "iowa", "idaho", "illinois", "indiana", "kansas", "kentucky", "louisiana", "massachusetts", "maryland", "maine", "michigan", "minnesota", "missouri", "mississippi", "montana", "northcarolina", "northdakota", "nebraska", "newhampshire", "newjersey", "newmexico", "nevada", "newYork", "ohio", "oklahoma", "oregon", "pennsylvania", "rhodeisland", "southcarolina", "southdakota", "tennessee", "texas", "utah", "virginia", "vermont", "washington", "wisconsin", "westVirginia", "wyoming" ]
    
    @driver = Selenium::WebDriver.for :chrome

    states.each do |state| 
      @l = 1
      begin
        @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
        lib_list = @wait.until {@driver.find_elements( :xpath, "//*[@id='libraries']/tbody/tr")}
        @driver.get ("http://www.publiclibraries.com/#{state}.htm")
        sleep(1)
        counter = lib_list.count
        lib_info(lib_list, counter, state)

      rescue Selenium::WebDriver::Error::UnknownError
        puts "Selenium::WebDriver::Error::UnknownError"
        retry

      rescue Net::ReadTimeout
        puts "Net::ReadTimeout"
        sleep (5.minutes)
        retry
      end
    end
  end


  def lib_info(lib_list, counter, state)
    until @l >= counter do
      info = lib_list[@l].find_elements(:css, "td")
      info_scrape(info, state)
    end
  end

  def info_scrape(info, state)
    name = info[1].text
    city = info.first.text
    address = info[2].text
    zip = info[3].text
    phone = info[4].text
    create_facility(name, state, city, address, zip, phone)
  end

  def create_facility(name, state, city, address, zip, phone)
    Facility.find_or_create_by(facility_name: name, facility_state: state, facility_city: city, facility_address: address, facility_zip_code: zip, facility_phone_number: phone)
    @l +=1
  end


end



