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
    @driver.get ("https://icsonline.icsolutions.com/rates")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    
    states_array = ["al", "ak", "az", "ar", "ca", "co", "ct", "de", "fl", "ga", "id", "il", "in", "ia", "ks", "ky", "la", "ma", "me", "md", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nj", "nh", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "va", "vt", "wa", "wv", "wi", "wy", "hi", "dc"]   
    @states_hash = {"AL" => ["Alabama", "205"], "AK" => ["Alaska", "907"], "AZ" => ["Arizona", "480"], "AR" => ["Arkansas", "479"], "CA" => ["California", "213"], "CO" => ["Colorado", "303"], "CT" => ["Connecticut", "203"], "DE" => ["Delaware", "302"], "DC" => ["District of Columbia", "202"], "FL" => ["Florida", "561"], "GA" => ["Georgia", "229"], "HI" => ["Hawaii", "808"], "ID" => ["Idaho", "208"], "IL" => ["Illinois", "217"], "IN" => ["Indiana", "219"], "IA" => ["Iowa", "319"], "KS" => ["Kansas", "316"], "KY" => ["Kentucky", "270"], "LA" => ["Louisiana", "225"], "ME" => ["Maine", "207"], "MD" => ["Maryland", "301"], "MA" => ["Massachusetts", "413"], "MI" => ["Michigan", "231"], "MN" => ["Minnesota", "218"], "MS" => ["Mississippi", "228"], "MO" => ["Missouri", "314"], "MT" => ["Montana", "406"], "NE" => ["Nebraska", "308"], "NV" => ["Nevada", "702"], "NH" => ["New Hampshire", "603"], "NJ" => ["New Jersey", "201"], "NM" => ["New Mexico", "505"], "NY" => ["New York", "212"], "NC" => ["North Carolina", "252"], "ND" => ["North Dakota", "701"], "OH" => ["Ohio", "216"], "OK" => ["Oklahoma", "405"], "OR" => ["Oregon", "503"], "PA" => ["Pennsylvania", "215"], "RI" => ["Rhode Island", "401"], "SC" => ["South Carolina", "803"], "SD" => ["South Dakota", "605"], "TN" => ["Tennessee", "423"], "TX" => ["Texas", "210"], "UT" => ["Utah", "435"], "VT" => ["Vermont", "802"], "VA" => ["Virginia", "276"], "WA" => ["Washington", "206"], "WV" => ["West Virginia", "304"], "WI" => ["Wisconsin", "262"], "WY" => ["Wyoming", "307"]}
    states_array.each do |state_name|
      @l = 0
      @c = 0
      state_info = @states_hash["#{state_name.upcase}"]
      get_facility(state_info)

      begin
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
        sleep(20)
        @driver.navigate().refresh()
        rescue_error(state_site)
      rescue Selenium::WebDriver::Error::UnknownError
        puts "Selenium::WebDriver::Error::UnknownError"
        @driver = Selenium::WebDriver.for :chrome
        sleep(1)
        rescue_error(state_site)
        retry
      end
    end
  end

  def get_facility(state_info)
    facility_form = @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[2]/div[2]/input")}.send_keys("#{state_info[0]}")
    state_fac_count = @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[2]/div[2]").find_elements(:css, "li").count}
    until @l >= state_fac_count do
      facility_form = @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[2]/div[2]/input")}.clear
      facility_form = @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[2]/div[2]/input")}.send_keys("#{state_info[0]}")
      @state_fac = @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[2]/div[2]").find_elements(:css, "li")[@l]}.text
      @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[2]/div[2]").find_elements(:css, "li")[@l]}.click
      select_fac(state_info)
      @l += 1
    end
    @driver.get ("https://icsonline.icsolutions.com/rates")
  end

  def select_fac(state_info)
    sleep(2)
    fac_count = @wait.until{@driver.find_elements(:xpath, "//*[@id='view-products']/div[1]/div/div[3]/div[2]/select/option").count}
    until @c >= fac_count do
      @driver.find_elements(:xpath, "//*[@id='view-products']/div[1]/div/div[3]/div[2]/select/option")[@c].click
      enter_phone(state_info)
      @c += 1
    end
  end

  def enter_phone(state_info)
    in_state(state_info)
  end
  
  def in_state(state_info)
    @driver.find_element(:id, "phone").clear
    @driver.find_element(:id, "phone").send_keys("#{state_info[-1]}3195215")
    @driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[5]/div/button").click
    calculate(state_info)
  end

  def calculate(state_info)
    sleep(2)
    @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[5]/div/div/table/tbody/tr[1]/td[2]")}
    initial_amount = @wait.until {@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[5]/div/div/table/tbody/tr[3]/td[2]/span")}.text.gsub("$", "").to_f
    per_min = @driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[5]/div/div/table/tbody/tr[4]/td[2]/span").text.gsub("$", "").to_f
    fifteen_mins = initial_amount + (per_min * 15)
    total = @driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[5]/div/div/table/tbody/tr[6]/td[2]/span/strong").text.gsub("$", "").to_f
    cost_array = [initial_amount, per_min, fifteen_mins, total]
    out_state(cost_array, state_info)
  end 

  def out_state(cost_array, state_info)
    @driver.find_element(:id, "phone").clear
    area_code = state_info[-1]
    if area_code == "561"
      area_code = "205"
    else
      area_code = "561"
    end
    @driver.find_element(:id, "phone").send_keys("#{area_code}3195215")
    @driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[5]/div/button").click
    sleep(2)
    compared_rate = @wait.until{@driver.find_element(:xpath, "//*[@id='view-products']/div[1]/div/div[5]/div/div/table/tbody/tr[6]/td[2]/span/strong").text}.gsub("$", "").to_f
    savings = (cost_array[-1] - compared_rate).round(2)
    names = get_name
    create_facility(names[0], names[-1], state_info[0], cost_array[0], cost_array[1], cost_array[2], cost_array[3], compared_rate, savings)
  end

  def get_name
    agency_name = @state_fac
    facility_name = @driver.find_elements(:xpath, "//*[@id='view-products']/div[1]/div/div[3]/div[2]/select/option")[@c].text
    return [agency_name, facility_name]
  end
  def create_facility(agency_name, name, state, initial_amount, per_min, fifteen_mins, total, compared_rate, savings)
    Facility.find_or_create_by(agency_name: agency_name, facility_name: name, facility_state: state, initial_amount: initial_amount, per_min: per_min, fifteen_mins: fifteen_mins, total: total, compared_rate: compared_rate, savings: savings)
  end
  #tax not recorded
  #instate = total
  #outstate = compared_rate

  def rescue_error(state_site)
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    binding.pry
  end
end