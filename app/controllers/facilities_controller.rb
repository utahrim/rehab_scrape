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


  #  At the end do: ["OR", "Oregon"]
  def search
    @driver = Selenium::WebDriver.for :chrome
    states_array = Array[["AK", "Alaska"], ["AL", "Alabama"],  ["AR", "Arkansas"], ["AZ", "Arizona"], ["CA", "California"], ["CO", "Colorado"], ["CT", "Connecticut"], ["DC", "District of Columbia"], ["DE", "Delaware"], ["FL", "Florida"], ["GA", "Georgia"], ["HI", "Hawaii"], ["IA", "Iowa"], ["ID", "Idaho"], ["IL", "Illinois"], ["IN", "Indiana"], ["KS", "Kansas"], ["KY", "Kentucky"], ["LA", "Louisiana"], ["MA", "Massachusetts"], ["MD", "Maryland"], ["ME", "Maine"], ["MI", "Michigan"], ["MN", "Minnesota"], ["MO", "Missouri"], ["MS", "Mississippi"], ["MT", "Montana"], ["NC", "North Carolina"], ["ND", "North Dakota"], ["NE", "Nebraska"], ["NH", "New Hampshire"], ["NJ", "New Jersey"], ["NM", "New Mexico"], ["NV", "Nevada"], ["NY", "New York"], ["OH", "Ohio"], ["OK", "Oklahoma"], ["OR", "Oregon"], ["PA", "Pennsylvania"], ["RI", "Rhode Island"], ["SC", "South Carolina"], ["SD", "South Dakota"], ["TN", "Tennessee"], ["TX", "Texas"], ["UT", "Utah"], ["VA", "Virginia"], ["VT", "Vermont"], ["WA", "Washington"], ["WI", "Wisconsin"],  ["WV", "West Virginia"], ["WY", "Wyoming"]]

    states_array.each do |state_site|
      @driver.get ("http://www.thegolfcourses.net/golfcourses/#{state_site[0]}/#{state_site[1].gsub(" ", "")}.htm")
      @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      @l = 0
      @c = 0
      begin
        city_list = @wait.until {@driver.find_element(:class, "overview").find_elements(:css, "li")}
        city_count = (city_list.count.to_i - 4)
        until @l >= city_count do
          
          if @l%10 == 0
            @driver.quit
            @driver = Selenium::WebDriver.for :chrome
            @driver.get ("http://www.thegolfcourses.net/golfcourses/#{state_site[0]}/#{state_site[1].gsub(" ", "")}.htm")
          end

          city_list = @wait.until {@driver.find_element(:class, "overview").find_elements(:css, "li")}
          sleep(1)
          name = city_list[@l].text.gsub(" ", "")
          @driver.get("http://www.thegolfcourses.net/golfcourses/#{state_site[0]}/#{name}.htm")
          city_click(state_site)
          @l += 1
        end
      rescue NoMethodError
        puts "NoMethodError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue Net::ReadTimeout
        puts "Net::ReadTimeout"
        @driver = Selenium::WebDriver.for :chrome
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::UnknownError
        puts "Selenium::WebDriver::Error::UnknownError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::UnhandledAlertError
        puts "Selenium::WebDriver::Error::UnhandledAlertError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::ElementNotVisibleError
        puts "Selenium::WebDriver::Error::ElementNotVisibleError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::TimeOutError
        puts "Selenium::WebDriver::Error::TimeOutError"
        sleep(1)
        rescue_error(state_site)
        retry
      end
    end
  end

  def city_click(state_site)
    course_list = @wait.until {@driver.find_elements(:css, "article")}
    course_count = course_list.count.to_i
    until @c >= course_count do
      course_list = @wait.until {@driver.find_elements(:css, "article")}
      click_list(course_list[@c].find_elements(:css, "a"))
      get_info(state_site)
    end
    @c = 0
    puts "City finished.."
    @driver.get ("http://www.thegolfcourses.net/golfcourses/#{state_site[0]}/#{state_site[1].gsub(" ", "")}.htm")
  end

  def click_list(course_list)
    if course_list.count == 1
      course_list.last.click()
    else
      course_list[1].click
    end
  end

  def get_info(state_site)
    name = @wait.until {@driver.find_element(:class, "entry-title").text}
    ad = get_address(@driver.find_element(:class, "address").text)
    city = ad[1]
    address = ad[0]
    zip = ad[2]
    phone_number = @driver.find_element(:class, "phone").text
    website = @driver.find_elements(:id, "listing-website") == [] ? "" : @driver.find_elements(:id, "listing-website").first.text

    architect = check_info(@driver.find_elements(:css, "div[class='cstat designicon']"))

    holes = check_info(@driver.find_elements(:css, "div[class='cstat holeicon']"))
    greens_fee_weekdays = check_info(@driver.find_elements(:css, "div[class='cstat moneyicon']"))
    
    year_built = check_info(@driver.find_elements(:css, "div[class='cstat builticon']"))
    driving_range = check_info(@driver.find_elements(:css, "div[class='cstat drivingicon']"))
    classification = check_info(@driver.find_elements(:css, "div[class='cstat coursetypeicon']"))
    
    description = @driver.find_elements(:class, "golf-description") == [] ? "" : @driver.find_element(:class, "golf-description").text
    staff = get_staff(@driver.find_element(:class, "staff").find_elements(:css, "div"))
    manager = staff["Manager"]
    superintendent = staff["Superintendent"]
    professional = staff["Golf Pro"]
    
    director_of_golf = staff["Director of Golf"]
    greens = check_info(@driver.find_elements(:css, "div[class='cstat grassicon']"))
    create_facility(name, city, state_site, address, zip, phone_number, description, classification, year_built, manager, architect, superintendent, professional, director_of_golf, website, holes, greens, greens_fee_weekdays)
 end

  def check_info(info)
    if info == []
      ""
    else
     return info.first.find_element(:class, "golf-data").text
    end
  end

  def get_staff(staff)
    workers = {"Manager" => "", "Golf Pro" => "", "Superintendent" => "", "Director of Golf" => "" }
    staff.each do |st|
      if st.text.include?("Manager: ")
        workers["Manager"] << st.text.gsub("Manager: ", "")
      elsif st.text.include?("Golf Pro: ")
        workers["Golf Pro"] << st.text.gsub("Golf Pro: ", "")
      elsif st.text.include?("Superintendent: ")
        workers["Superintendent"] << st.text.gsub("Course Superintendent: ", "")
      elsif st.text.include?("Director of Golf: ")
        workers["Director of Golf"] << st.text.gsub("Director of Golf: ", "")
      end
    end
    return workers
  end

  def get_address(address)
    ad = []
    address = address.split(", ")
    ad << address[0]
    ad << address[1]
    ad << address.last.split(" ").last
    return ad
  end
  
  def create_facility(name, city, state, address, zip, phone_number, description, classification, year_built, manager, architect, superintendent, professional, director_of_golf, website, holes, greens, greens_fee_weekdays)

    Facility.find_or_create_by!(name: name, city: city, state: state[1], address: address, zip: zip, phone_number: phone_number, description: description, classification: classification, year_built: year_built, manager: manager, architect: architect, superintendent: superintendent, professional: professional, director_of_golf: director_of_golf, website: website, holes: holes, greens: greens, greens_fee_weekdays: greens_fee_weekdays)
    @driver.navigate.back()
    @c += 1
  end

  def rescue_error(state_site)
    @driver.quit
    @driver = Selenium::WebDriver.for :chrome       
    @driver.get ("http://www.thegolfcourses.net/golfcourses/#{state_site[0]}/#{state_site[1].gsub(" ", "")}.htm")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    @c += 1
  end

end


