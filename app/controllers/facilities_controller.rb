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
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)

    states = ["Texas", "Hawaii", "Iowa", "Idaho", "Illinois", "Indiana", "Kansas", "Kentucky", "Louisiana", "Massachusetts", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "Mississippi", "Montana", "North-Carolina", "North-Dakota", "New-Hampshire", "Nebraska", "New-Jersey", "New-Mexico", "Nevada", "New-York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode-Island", "South-Carolina", "South-Dakota", "Tennessee", "Utah", "Virginia", "Vermont", "Washington", "Wisconsin", "West-Virginia", "Wyoming", "Alaska", "Alabama", "Arkansas", "Arizona", "California", "Colorado", "Connecticut", "District-of-Columbia", "Delaware", "Florida", "Georgia"]

      #Georgia
      #New-Hampshire
      #Texas
    states.each do |state|
      @l = 0
      begin
        @driver.get("http://www.firedepartment.net/directory/#{state}")
        county_array = @wait.until {@driver.find_elements(:xpath, "//*[@id='content']/div/div[1]/div[2]/table/tbody/tr")}
        counter = county_array.count
        info_scrape(county_array, counter, state)

      rescue Net::ReadTimeout
        puts "Net::ReadTimeout"
        sleep (5.minutes)
      retry
      end
    end
  end


  def info_scrape(county_array, counter, state)
    until @l >= counter do
      county_array = @wait.until {@driver.find_elements(:xpath, "//*[@id='content']/div/div[1]/div[2]/table/tbody/tr")}
      county_array[@l].find_element(:css, "a").click
      county_scrape(state)
      @driver.navigate.back()
    end
  end

  def county_scrape(state)
    county = @wait.until {@driver.find_element(:xpath, "/html/body/div[2]/div[2]/div/span").text}
    sleep(1)
    county = @driver.find_element(:xpath, "/html/body/div[2]/div[2]/div/span").text
    @i = 0
    fire_dep = @driver.find_elements(:class, "department")
    counter1 = fire_dep.count
    until @i >= counter1 do
      begin
        fire_dep = @wait.until {@driver.find_elements(:class, "department")}
        sleep(1)
        fire_dep = @driver.find_elements(:class, "department")
        name = fire_dep[@i].text
        fire_dep[@i].click
        data_scrape(name, state, county)
        @driver.navigate.back()

      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        puts "Selenium::WebDriver::Error::StaleElementReferenceError"
        @driver.navigate.back()
        @i +=1
        retry

      rescue Selenium::WebDriver::Error::UnknownError
        puts "Selenium::WebDriver::Error::UnknownError"
        @i +=1
        retry

      rescue Selenium::WebDriver::Error::TimeOutError
        puts "Selenium::WebDriver::Error::TimeOutError"
        @driver.navigate.back()
        @i +=1
        retry

      rescue NoMethodError
        puts "NoMethodError"
        @i +=1
        retry
      end
    end
    @l += 1
  end

  def data_scrape(name, state, county)
    address = @wait.until {@driver.find_element(:xpath, "//div[@itemprop='streetAddress']").text}
    city = @driver.find_element(:xpath, "//span[@itemprop='addressLocality']").text
    zip_code = @driver.find_element(:xpath, "//span[@itemprop='postalCode']").text
    
    begin
      phone_text = @driver.find_element(:class, "phone").text
      phone = phone_text.match(/\W\d+\W+\d+\W+\d+/)[0]
    rescue Selenium::WebDriver::Error::NoSuchElementError
      phone = ""
    rescue NoMethodError
      phone = ""
    end
    record_data(name, state, county, city, address, zip_code, phone)
  end

  def record_data(name, state, county, city, address, zip_code, phone)
    Facility.find_or_create_by(facility_name: name, facility_state: state, facility_county: county, facility_city: city, facility_address: address, facility_zip: zip_code, facility_phone_number: phone)
    @i += 1
  end


  # def rescue_error(state_site, number)
  #   @driver.get ("https://www.brbpublications.com/freesites/FreeSitesState.aspx?S1=#{state_site}")
  #   @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
  #   list_array = @wait.until {@driver.find_elements(:id, "#{number}")}
  # end
end


