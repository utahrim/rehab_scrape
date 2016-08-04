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

    states_array = ["al", "ak", "az", "ar", "ca", "co", "ct", "de", "dc", "fl", "ga", "hi", "ID", "il", "in", "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or",  "pa", "ri", "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy"]

    states_array.each do |state_site|
      @driver.get ("https://www.brbpublications.com/freesites/FreeSitesState.aspx?S1=#{state_site}")
      @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      county_list = ["ContentPlaceHolder1_CellCountyList", "ContentPlaceHolder1_CellCountyList2"]
      county_list.each do |number|
        @l = 0
        begin
          list_array = @wait.until {@driver.find_elements(:id, "#{number}")}
          sleep(1)
          list = list_array.first.find_elements(:css, 'a')
          info_counter = list.count - 1
          click(info_counter, number)

        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          puts "Selenium::WebDriver::Error::StaleElementReferenceError"
          sleep(1)
          rescue_error(state_site, number)
          retry
        rescue NoMethodError
          puts "NoMethodError"
          sleep(1)
          @l += 1
          rescue_error(state_site, number)
          retry
        rescue Net::ReadTimeout
          puts "Net::ReadTimeout"
          sleep(10.minutes)
          rescue_error(state_site, number)
          retry
        rescue Selenium::WebDriver::Error::UnknownError
          puts "Selenium::WebDriver::Error::UnknownError"
          sleep(1)
          rescue_error(state_site, number)
          retry
        end
      end
    end
  end

  # def page_loop(state_site, info_counter)
  #   until @p > pages || @p > 25 do
  #     click(info_counter)
  #     @p += 1
  #     @driver.get ("https://www.brbpublications.com/freesites/FreeSitesState.aspx?S1={state_site}")
  #   end
  # end

  def click(info_counter, number)
    until @l > info_counter do
      state_page = @wait.until {@driver.find_elements(:id, "#{number}")}
      list = state_page.first.find_elements(:css, 'a')
      sleep(1)
      list[@l].click
      scrape
      @driver.navigate.back()
      sleep(1)
    end
  end

  def scrape
    info_list = @wait.until {@driver.find_elements(:xpath, "//table[2]/tbody/tr/td[@align='left']/font")}
    sleep(1)
    counter = info_list.count - 3
    @i = 0
    until @i > counter
      info_list = @driver.find_elements(:xpath, "//table[2]/tbody/tr/td[@align='left']/font")
      get_info(info_list)
    end
    @l += 1
  end

  def get_info(info_list)
    info_array = info_list[@i].text.split("\n")
    name = info_array[0]
    address = info_array[1]
    place = info_array[2].split(", ")
    city = place[0]
    state = place[1].split(" ").first
    zip = place[1].split(" ").last
    phone = info_array[-3].match(/\d.+/)[0]
    extra_info = info_array.last
    create_facility(name, city, state, zip, address, phone, extra_info)
  end

  def create_facility(name, city, state, zip, address, phone, extra_info)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_zip: zip, facility_address: address, facility_phone_number: phone, facility_extra_info: extra_info)
    @i += 1
  end

  def rescue_error(state_site, number)
    @driver.get ("https://www.brbpublications.com/freesites/FreeSitesState.aspx?S1=#{state_site}")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    list_array = @wait.until {@driver.find_elements(:id, "#{number}")}
  end
end