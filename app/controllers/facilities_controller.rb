class FacilitiesController < ApplicationController

  def index
  end

  def update
    facility = Facility.all
    facility.each do |fac|
      if fac.facility_county == "County:"
        f_city = fac.facility_city.split.map(&:capitalize).join(' ')
        if Location.where(city: "#{f_city}") != [] 
          f_county = Location.where(city: "#{f_city}").where(state: "#{fac.facility_state}")
          binding.pry
          fac.update_attributes(:facility_county, f_county.first.county)
          fac.save
          print"#{fac.name} updated #{fac.county}, #{fac.state}\n"
        end
      end
    end
  end

  def data
    @facilities = Facility.all
    respond_to do |format|
      format.html
      format.csv { send_data @facilities.to_csv, filename: "facilities-#{Date.today}.csv" }
    end
  end

  #  At the end do: get_pages("dc", "DC") 
  # {"AL" => "Alabama", "AK" => "Alaska", "AZ" => "Arizona", "AR" => "Arkansas", "CA" => "California", "CO" => "Colorado", "CT" => "Connecticut", "DE" => "Delaware", "DC" => "District of Columbia", "FL" => "Florida", "GA" => "Georgia", "HI" => "Hawaii", "ID" => "Idaho", "IL" => "Illinois", "IN" => "Indiana", "IA" => "Iowa", "KS" => "Kansas", "KY" => "Kentucky", "LA" => "Louisiana", "ME" => "Maine", "MD" => "Maryland", "MA" => "Massachusetts", "MI" => "Michigan", "MN" => "Minnesota", "MS" => "Mississippi", "MO" => "Missouri", "MT" => "Montana", "NE" => "Nebraska", "NV" => "Nevada", "NH" => "New Hampshire", "NJ" => "New Jersey", "NM" => "New Mexico", "NY" => "New York", "NC" => "North Carolina", "ND" => "North Dakota", "OH" => "Ohio", "OK" => "Oklahoma", "OR" => "Oregon", "PA" => "Pennsylvania", "RI" => "Rhode Island", "SC" => "South Carolina", "SD" => "South Dakota", "TN" => "Tennessee", "TX" => "Texas", "UT" => "Utah", "VT" => "Vermont", "VA" => "Virginia", "WA" => "Washington", "WV" => "West Virginia", "WI" => "Wisconsin", "WY" => "Wyoming"}




  def search
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(:timeout => 40)
    standings = {"1" => "North American Summer 2017", "2" => "European Summer 2017" , "6" => "North American Fall 2017"}
    standings.each do |stand|
      @driver.get ("http://halodatahive.com/League/Standings/#{stand[0]}")
      @wait.until {@driver.find_elements(:class, "full-tabs")}[1].find_element(:css, "a").click
      @f = 1
      @d = 0
      get_fixtures(stand)
      begin
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        puts "Selenium::WebDriver::Error::StaleElementReferenceError"
        sleep(1)
        rescue_error(state_site)
        retry
      rescue NoMethodError
        puts "NoMethodError"
        sleep(3)
        rescue_error(state_site)
        retry
      rescue Net::ReadTimeout
        puts "Net::ReadTimeout"
        sleep(20)
        binding.pry
        rescue_error(state_site)
        retry
      rescue Selenium::WebDriver::Error::TimeOutError
        puts "Selenium::WebDriver::Error::TimeOutError"
        sleep(1)
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

  def get_fixtures(stand)
    dates = @wait.until {@driver.find_elements(:class, "group")}
    d_ate = []
    dates.each {|date| d_ate << date.text}
    fix_list_count = @driver.find_elements(:css, "tbody")[1].find_elements(:css, "tr").count
    until @f >= fix_list_count  do
      @wait.until {@driver.find_elements(:class, "full-tabs")}[1].find_element(:css, "a").click
      fix_list = @wait.until{@driver.find_elements(:css, "tbody")[1].find_elements(:css, "tr")}
      if fix_list[@f].text == d_ate[@d + 1]
        @d += 1
        @f += 1
      else
        data = fix_list[@f].attribute("data-id")
        teams = [] 
        fix_list[@f].find_elements(:class, "fixture-team-name").each{|team| teams << team.text}
        @driver.get("http://halodatahive.com/Scrim/Summary/#{data}")
        get_stats(d_ate, stand, teams)
        @f += 1
      end
    end
    @f = 1
    @d = 0
  end

  def get_stats(d_ate, stand, teams)
    @g = 0
    s_table_count = @wait.until{@driver.find_element(:class, "table-responsive").find_elements(:css, "tr").count}
    until @g >= s_table_count do 
      s_table = @driver.find_element(:class, "table-responsive").find_elements(:css, "tr")[@g]
      get_info(s_table, d_ate, stand, teams)
      @g += 1
    end
    @driver.navigate.back()
  end

  def get_info(s_table, d_ate, stand, teams)
    match_id = s_table.attribute("data-href").gsub("/Match/Detail/", "")
    team_a = teams.first
    team_b = teams.last
    date = d_ate[@d]
    season = stand[1]
    create_facility(date, season, team_a, team_b, match_id)
  end

  #date = name, season = city, team_a = county, team_b = state, match_id = address 

  def create_facility(name, city, county, state, address)
    Facility.find_or_create_by(facility_name: name, facility_city: city, facility_state: state, facility_county: county, facility_address: address)
  end

  def rescue_error(state_site)
    binding.pry
    @driver.get ("http://halodatahive.com/League/Standings/#{stand[0]}")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 40)
  end

end