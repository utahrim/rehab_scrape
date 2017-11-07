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
  # "al", "ak", "az", "ar", "ca", "co", "ct", "de", "fl", "ga", "id", "il", "in", "ia", "ks", "ky", "la", "ma", "me", "md", "mi", "mn", "ms", "mo", "mt", "ne", "nv", "nj", "nh", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", "ri", "sc", "sd", "tn", "tx", "ut", "va", "vt", "wa", "wv", "wi", "wy", "hi", "dc"   
  def search
    @driver = Selenium::WebDriver.for :chrome
    @driver.get ("https://securustech.net/call-rate-calculator")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    
    @states_hash = {"AL" => ["Alabama", "205"], "AK" => ["Alaska", "907"], "AZ" => ["Arizona", "480"], "AR" => ["Arkansas", "479"], "CA" => ["California", "213"], "CO" => ["Colorado", "303"], "CT" => ["Connecticut", "203"], "DE" => ["Delaware", "302"], "DC" => ["District of Columbia", "202"], "FL" => ["Florida", "561"], "GA" => ["Georgia", "229"], "HI" => ["Hawaii", "808"], "ID" => ["Idaho", "208"], "IL" => ["Illinois", "217"], "IN" => ["Indiana", "219"], "IA" => ["Iowa", "319"], "KS" => ["Kansas", "316"], "KY" => ["Kentucky", "270"], "LA" => ["Louisiana", "225"], "ME" => ["Maine", "207"], "MD" => ["Maryland", "301"], "MA" => ["Massachusetts", "413"], "MI" => ["Michigan", "231"], "MN" => ["Minnesota", "218"], "MS" => ["Mississippi", "228"], "MO" => ["Missouri", "314"], "MT" => ["Montana", "406"], "NE" => ["Nebraska", "308"], "NV" => ["Nevada", "702"], "NH" => ["New Hampshire", "603"], "NJ" => ["New Jersey", "201"], "NM" => ["New Mexico", "505"], "NY" => ["New York", "212"], "NC" => ["North Carolina", "252"], "ND" => ["North Dakota", "701"], "OH" => ["Ohio", "216"], "OK" => ["Oklahoma", "405"], "OR" => ["Oregon", "503"], "PA" => ["Pennsylvania", "215"], "RI" => ["Rhode Island", "401"], "SC" => ["South Carolina", "803"], "SD" => ["South Dakota", "605"], "TN" => ["Tennessee", "423"], "TX" => ["Texas", "210"], "UT" => ["Utah", "435"], "VT" => ["Vermont", "802"], "VA" => ["Virginia", "276"], "WA" => ["Washington", "206"], "WV" => ["West Virginia", "304"], "WI" => ["Wisconsin", "262"], "WY" => ["Wyoming", "307"]}
      @l = 42
      state_count = @wait.until {@driver.find_element(:id, "stateCode").find_elements(:css, "option").count}
      until @l >= state_count do
        select_state = @driver.find_element(:id, "stateCode").find_elements(:css, "option")
        select_state[@l].click
        sleep(0.5)
        find_state(select_state[@l])
        @l += 1
        sleep(1)
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

  def find_state(state)
    @info = @states_hash[state.text]
    find_facility
  end

  def find_facility
    @c = 1
    facility_count = @driver.find_element(:id, "siteId").find_elements(:css, "option").count
    until @c >= facility_count do
      facility_list = @driver.find_element(:id, "siteId").find_elements(:css, "option")
      facility_list[@c].click
      name = facility_list[@c].text
      state = @info.first
      calc_array = in_state_cost(@info[1])
      create_facility(name, state, "$ #{calc_array[0]}", "$ #{calc_array[1]}", "$ #{calc_array[2]}", "$ #{calc_array[3]}", "$ #{calc_array[4]}", "$ #{calc_array[5]}")
      @c += 1
    end
  end

  def out_state_cost(cost_array, area_code)
    form = @driver.find_element(:id, "contactPhoneNumber")
    if area_code == "561"
      area_code = "252"
    else
      area_code = "561"
    end
    form.clear()
    form.send_keys("#{area_code}3195215")
    @driver.find_element(:xpath, "//*[@id='CallRateCalcForm']/div[6]/input[2]").click
    sleep(1.0)
    cost = @driver.find_element(:xpath, "//*[@id='details']/div[3]/table/tbody").text
    main_array = rate(cost, cost_array)
    return main_array
  end

  def rate(cost, cost_array)
    split_c = cost.split("$")
    initial_amount = split_c[2].to_f
    per_min = split_c[3].to_f
    compared_rate = initial_amount +(per_min * 15)
    savings = cost_array[-1] - compared_rate
    cost_array << compared_rate.round(2)
    cost_array << savings.round(2)
    return cost_array
  end

  def calculate_cost(cost)
    split_c = cost.split("$")
    initial_amount = split_c[2].to_f
    per_min = split_c[3].to_f
    fifteen_mins = (per_min *15).round(2)
    total = fifteen_mins + initial_amount
    cost_array = [initial_amount, per_min, fifteen_mins, total.round(2)]
    return out_state_cost(cost_array, @info[1])
  end

  def in_state_cost(area_code)
    form = @driver.find_element(:id, "contactPhoneNumber")
    form.clear()
    form.send_keys("#{area_code}3195215")
    sleep(0.5)
    @driver.find_element(:xpath, "//*[@id='CallRateCalcForm']/div[6]/input[2]").click
    sleep(1.0)
    cost = @driver.find_element(:xpath, "//*[@id='details']/div[3]/table/tbody").text
    calc_array = calculate_cost(cost)
    return calc_array
  end
  
  def create_facility(name, state, initial_amount, per_min, fifteen_mins, total, compared_rate, savings)
    Facility.find_or_create_by(facility_name: name, facility_state: state, initial_amount: initial_amount, per_min: per_min, fifteen_mins: fifteen_mins, total: total, compared_rate: compared_rate, savings: savings)
  end

  def rescue_error(state_site)
    @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    binding.pry
  end

end