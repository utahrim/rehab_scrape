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
    driver = Selenium::WebDriver.for :firefox
    driver.get ("http://www.drugrehabexchange.com/find/SubstanceAbuseTreatment/?state=Florida")
    page_array = driver.find_elements(:class, "k-link")
    pages = page_array[23].attribute("data-page").to_i
    (pages - 1).times do
      l = 0
      pf = 1
      tc = 2
      data_list = driver.find_elements(:xpath, "//td[@role='gridcell']")
      while data_list[l] != nil do
        sleep(1)
        data_list = driver.find_elements(:xpath, "//td[@role='gridcell']")
        name_loc = data_list[l].text.split("\n") 
        name = name_loc[0]
        loc = name_loc.last
        loc_array = loc.split(" - ")
        city = loc_array[0].sub("City of ", "")
        county = loc_array[1]
        state = loc_array.last
        primary_focus = data_list[pf].text
        type_care = data_list[tc].text
        data_list[l].click
        sleep(2)
        det = driver.find_elements(:class, "details")
        details = det[0].text.split("\n")
        address = details[3] + ", " + details[4]
        phone = details[10].match(/.\d+..\d+.\d+/).to_s
        Facility.find_or_create_by(facility_name: name, facility_city: city, facility_county: county, facility_state: state, facility_primary_focus: primary_focus, facility_type_of_care: type_care, facility_address: address, facility_phone_number: phone)
        l += 3
        pf += 3
        tc += 3
        driver.navigate.back()
        driver.navigate.forward()
        page_array = driver.find_elements(:class, "k-link")
      end
      binding.pry
      page_array[22].click
      page_array = driver.find_elements(:class, "k-link")
    end
  end

end