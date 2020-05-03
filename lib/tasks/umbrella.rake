task(:umbrella) do 
  require 'json'

  user_address = "Poplar Bluff"

  geocoding_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_address + "&key=" + ENV.fetch("GEOCODING_API_KEY")
  address_raw_file = open(geocoding_url).read
  address_parsed_file = JSON.parse(address_raw_file)
  longitude = address_parsed_file["results"][0]["geometry"]["location"]["lng"]
  latitude = address_parsed_file["results"][0]["geometry"]["location"]["lat"]
  
  darksky_url = "https://api.darksky.net/forecast/" + ENV.fetch("DARKSKY_API_KEY") + "/" + latitude.to_s + "," + longitude.to_s
  darksky_raw_file = open(darksky_url).read
  darksky_parsed_file = JSON.parse(darksky_raw_file) 
  currently = darksky_parsed_file["currently"]
  currentTemperature = currently["temperature"]
  currentTime = Time.at(currently["time"])
  
  hourly = darksky_parsed_file.fetch("hourly") 
  nextHourOutlook = hourly["data"][0]["temperature"]
  fewHourOutlook = hourly["summary"]

  #precipitation probability for next 12 hours
  i = 0
  umbrella = false
  while i < 12 do
    percipAtHour = hourly["data"][i]["precipProbability"] 
    if percipAtHour > 0.5 
      umbrella = true 
      break;
    end 
    i = i + 1
  end

  p "----Your Personal Weather Forecast Assistant----"
  p "Current Time: " + currentTime.to_s
  p "Current Temperature: " + currentTemperature.to_s
  p "Temperature in Next Hour: " + nextHourOutlook.to_s
  p "Summary of Oulook for Next Hour: " + fewHourOutlook.to_s
  if umbrella == false 
    p "Given the outlook for the next 12 hours, we recommend you do not carry an umbrella" 
  else 
    p "Given the outlook for the next 12 hours, we recommend you do carry an umbrella" 
  end

end