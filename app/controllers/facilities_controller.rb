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
    states_array = ["al", "ak", "az", "ar", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy"]

    state_array.each do |state_site|
      @driver.get ("http://www.countyoffice.org/#{state_site}-police-department/")
      @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      page_array = @wait.until {@driver.find_elements(:xpath, "//td")}
      info_counter = page_array.count - 1
      page_loop(state_site, info_counter)
    end
  end

  def page_loop(state_site, info_counter)
    pages = @wait.until {@driver.find_elements(:xpath, "//li").last.text.to_i}
    @p = 1
    until @p > pages do
      @l = 0
      click(info_counter)
      @p += 1
      @driver.get ("http://www.countyoffice.org/#{state_site}-police-department-p#{@p}/")
    end
  end

  def click(info_counter)
    until @l > info_counter do
      page_array = @wait.until {@driver.find_elements(:xpath, "//td")}
      page_array[@l].click
      scrape
      @driver.navigate.back()
    end
  end

  def scrape
    load_name = @wait.until {@driver.find_elements(:class, "name")}
    name = load_name.first.text
    city = @driver.find_elements(:class, "addressLocality").first.text
    state = @driver.find_elements(:class, "addressRegion").first.text
    address = @driver.find_elements(:class, "address").first.text
    phone = @driver.find_elements(:class, "telephone").first.text
    create_facility(name, city, state, address, phone)
  end

  def create_facility(name, city, state, address, phone)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_address: address, facility_phone_number: phone)
    @l += 3
  end

end