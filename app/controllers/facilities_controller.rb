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
  def search
    @driver = Selenium::WebDriver.for :chrome
    states_array = ["al", "ak", "az", "ar", "ca", "co", "ct", "dc", "de", "fl", "ga", "hi", "id", "il", "in", "ia", "ks", "ky", "la", "ma", "me", "md", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nj", "nh", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "va", "vt", "wa", "wv", "wi", "wy"]
    states_array.each do |state_site|
      @driver.get ("http://www.countyoffice.org/#{state_site}-assisted-living-nursing-home/")
      @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      @l = 0
      @c = 0
      begin
        county_list = @wait.until {@driver.find_elements(:xpath, "/html/body/div/div/div[1]/div[3]/ul/li")}
        county_count = county_list.count
        until @c >= county_count do
          county_list = @wait.until {@driver.find_elements(:xpath, "/html/body/div/div/div[1]/div[3]/ul/li")}
          county = county_list[@c].text
          county_list[@c].find_element(:css, "a").click
          check_page(state_site, county)
          @c += 1
        end
   

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
        sleep(2.minutes)
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

  def check_page(state_site, county)
    if @wait.until {@driver.find_elements(:css, "p[class='condensed-listing']")} != []
      get_pages(state_site, county)
    else
      get_info(state_site, county)
    end
    @driver.get ("http://www.countyoffice.org/#{state_site}-assisted-living-nursing-home/")
  end

  def get_pages(state_site, county)
    @p = 1
    binding.pry
    pages = @wait.until {@driver.find_elements(:xpath, "/html/body/div[2]/div/div[1]/nav[1]/ul/li").last.text.to_i}
    until @p > pages do
      click_facility(state_site, county)
    end
    @driver.get ("http://www.countyoffice.org/#{state_site}-assisted-living-nursing-home/")
  end



  def get_info(state_site, county)
     f_array = @wait.until {@driver.find_elements(:class, "dl-horizontal")}
     f_count = f_array.count
     if f_count == 1
      scrape(state_site, county)
    else
      f_array.each do |f|
        scrape2(state_site, county, f)
      end
    end
  end

  def click_facility(state_site, county)
    facility_array = @wait.until {@driver.find_elements(:css, "p[class='condensed-listing']")}
    counter = facility_array.count
    until @l >= counter do
      page_array = @wait.until {@driver.find_elements(:css, "p[class='condensed-listing']")}
      page_array[@l].click()
      scrape(state_site, county)
      @l += 1
    end
    @p += 1
    @l = 0
    @driver.get("http://www.countyoffice.org/#{state_site}-#{county.downcase.gsub(" ", "-")}-assisted-living-nursing-home-p#{@p}/")
  end

  def scrape(state_site, county)
    name = @wait.until {@driver.find_elements(:class, "name").first.text}
    city = @driver.find_elements(:class, "addressLocality").first.text
    state = @driver.find_elements(:class, "addressRegion").first.text
    address = @driver.find_elements(:class, "streetAddress").first.text
    zip = @driver.find_elements(:class, "postalCode").first.text
    phone = @driver.find_elements(:class, "telephone").blank? ? nil : @driver.find_elements(:class, "telephone").first.text
    fax = @driver.find_elements(:class, "fax").blank? ? nil : @driver.find_elements(:class, "fax").first.text
    county = county
    create_facility(name, city, state, county, address, zip, phone, fax)
    @driver.navigate.back()
  end

  def scrape2(state_site, county, f)
    name = @wait.until {f.find_elements(:class, "name").first.text}
    city = f.find_elements(:class, "addressLocality").first.text
    state = f.find_elements(:class, "addressRegion").first.text
    address = f.find_elements(:class, "streetAddress").first.text
    zip = @driver.find_elements(:class, "postalCode").first.text
    phone = f.find_elements(:class, "telephone").blank? ? nil : f.find_elements(:class, "telephone").first.text
    fax = f.find_elements(:class, "fax").blank? ? nil : f.find_elements(:class, "fax").first.text
    county = county
    create_facility(name, city, state, county, address, zip, phone, fax)
  end

  def create_facility(name, city, state, county, address, zip, phone, fax)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_county: county, facility_address: address, facility_zip: zip, facility_phone_number: phone, facility_fax: fax)
  end

  def rescue_error(state_site)
    @driver.get ("http://www.countyoffice.org/#{state_site}-assisted-living-nursing-home/")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    @page_array =  @wait.until { @driver.find_elements(:css, "p[class='condensed-listing']") }
    @l += 1
  end

end