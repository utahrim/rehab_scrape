class FacilitiesController < ApplicationController

  def index
  end

  def data
    @facilities = Facility.all
    # @facilities.each do |f|
    #   if f.facility_city.include?(" of ")
    #     city = f.facility_city.sub!(" of ", "")
    #     f.update_attribute(:facility_city, city)
    #   end
    # end 
    respond_to do |format|
      format.html
      format.csv { send_data @facilities.to_csv, filename: "facilities-#{Date.today}.csv" }
    end
  end

  def search
    @driver = Selenium::WebDriver.for :chrome
    states_array = ["Delaware", "Florida", "Georgia", "Hawaii", "Iowa", "Idaho", "Illinois", "Indiana", "Kansas", "Kentucky", "Louisiana", "Massachusetts", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "Mississippi", "Montana", "North%20Carolina", "North%20Dakota", "Nebraska", "New%20Hampshire", "New%20Jersey", "New%20Mexico", "Nevada", "New%20York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode%20Island", "South%20Carolina", "South%20Dakota", "Tennessee", "Texas", "Utah", "Virginia", "Vermont", "Washington", "Wisconsin", "West%20Virginia", "Wyoming", "Alaska", "Alabama", "Arkansas", "Arizona", "California", "Colorado", "Connecticut", "District%20of%20Columbia"]
    states_array.each do |state_site|
      @driver.get ("http://www.drugrehabexchange.com/find/SubstanceAbuseTreatment/?state=#{state_site}")
      @page_array = @driver.find_elements(:class, "k-link")
      sleep(1)
      @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      @page_clicks = 1
      begin
        pages = @page_array[-1].attribute("data-page").to_i
        while @page_clicks < pages do
          @l = 0
          @pf = 1
          @tc = 2
          data_list1 = @driver.find_elements(:xpath, "//td[@role='gridcell']")

          while data_list1[@l] != nil || @l < 24 do
            data_list = @wait.until { @driver.find_elements(:xpath, "//td[@role='gridcell']") }
            sleep(2)
            @data_list = @driver.find_elements(:xpath, "//td[@role='gridcell']")
            sleep(1)
            if @driver.find_elements(:class, "k-link")[-2].attribute("class") == "k-link k-state-disabled"
              break
            else
            get_params(@data_list)
            sleep(1)
            @data_list[@l].click

            det = @wait.until { @driver.find_elements(:class, "details") }
            det = @driver.find_elements(:class, "details")
            
            get_details(det)
            sleep(1)
            
            @driver.navigate.back()
            clicks(@page_clicks)
            end
          end
          @page_array = @wait.until { @driver.find_elements(:class, "k-link") }
          @page_clicks += 1
          puts "#{@page_clicks}"
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
          sleep(15.minutes)
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


  def rescue_error(state_site)
    @driver.get ("http://www.drugrehabexchange.com/find/SubstanceAbuseTreatment/?state=#{state_site}")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    sleep(1)
    @page_array =  @wait.until { @driver.find_elements(:class, "k-link") }
  end


  def get_params(d_list)
    name_loc = d_list[@l].text.split("\n")
    @name = name_loc.count > 2 ? name_loc[0] + " - " + name_loc[1] : name_loc[0]
    loc = name_loc.last
    loc_array = loc.split(" - ")
    @city = loc_array[0].sub("City of ", "")
    @county = loc_array[1]
    @state = loc_array.last
    @primary_focus = @data_list[@pf].text
    @type_care = @data_list[@tc].text
  end

  def get_details(det)
    details = det[0].text.split("\n")
    address = details[3] + ", " + details[4]
    phone = details[-1].match(/.\d+.+\d+.\d+/).to_s
    create_facility(@name, @city, @county, @state, @primary_focus, @type_care, address, phone)
  end

  def create_facility(name, city, county, state, primary_focus, type_care, address, phone)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_county: county, facility_state: state, facility_primary_focus: primary_focus, facility_type_of_care: type_care, facility_address: address, facility_phone_number: phone)
    @l += 3
    @pf += 3
    @tc += 3
  end

  def clicks(n)
    num = n - 1
    skips = num/10
    skips.times do 
      page_array = @wait.until { @driver.find_elements(:class, "k-link") }
      sleep(1)
      page_array = @driver.find_elements(:class, "k-link")
      sleep(1)
      page_array[-3].click
    end
    page = num%10
    if page >= 5 
      page_array = @wait.until { @driver.find_elements(:class, "k-link") }
      sleep(1)
      page_array = @driver.find_elements(:class, "k-link")
      sleep(1)
      page_array[16].click
      page -= 5
    end
    page.times do
      page_array = @wait.until { @driver.find_elements(:class, "k-link") }
      sleep(1)
      page_array = @driver.find_elements(:class, "k-link")
      sleep(1)
      page_array[-2].click
    end
  end

end