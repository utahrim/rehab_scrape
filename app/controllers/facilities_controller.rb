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
    states_array = ["de", "dc", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy", "al", "ak", "az", "ar", "ca", "co", "ct"]
    states_array.each do |state_site|
      @driver.get ("http://www.countyoffice.org/#{state_site}-elections/")
      @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      @p = 1
      @l = 0
      begin
        page_array = @wait.until {@driver.find_elements(:class, "mob-clip")}
        info_counter = page_array.count - 1
        page_loop(state_site, info_counter)

      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        puts "Selenium::WebDriver::Error::StaleElementReferenceError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue NoMethodError
        puts "NoMethodError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue Net::ReadTimeout
        puts "Net::ReadTimeout"
        sleep(5.minutes)
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

  def page_loop(state_site, info_counter)
    pages = @wait.until {@driver.find_elements(:xpath, "//li").last.text.to_i}
    until @p > pages do
      click(info_counter)
      @p += 1
      @driver.get ("http://www.countyoffice.org/#{state_site}-elections-p#{@p}/")
    end
  end

  def click(info_counter)
    until @l > info_counter do
      show_page = @wait.until {@driver.find_elements(:class, "mob-clip")}
      sleep(1)
      show_page[@l].click
      scrape
      @driver.navigate.back()
      sleep(1)
    end
  end

  def scrape
    load_name = @wait.until {@driver.find_elements(:class, "name")}
    sleep(1)
    name = load_name.first.text
    city = @driver.find_elements(:class, "addressLocality").first.text
    state = @driver.find_elements(:class, "addressRegion").first.text
    address = @driver.find_elements(:class, "address").first.text
    phone = @driver.find_elements(:class, "telephone").blank? ? nil : @driver.find_elements(:class, "telephone").first.text
    create_facility(name, city, state, address, phone)
  end

  def create_facility(name, city, state, address, phone)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_address: address, facility_phone_number: phone)
    @l += 1
  end

  def rescue_error(state_site)
    @driver.get ("http://www.countyoffice.org/#{state_site}-elections-p#{@p}/")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    @page_array =  @wait.until { @driver.find_elements(:class, "mob-clip") }
  end
end

# url_array = ["assesor", "elections", "chamber-of-commerce", "child-support-offices", "clerk", "colleges", "madical-corner", "courts", "motor-vehicles-dmv", "district-attorney", "fire-departments", "hospitals", "irs-offices", "jails-prisons" ]