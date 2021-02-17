defmodule Tasks.WeatherGetter do
  @locations [
    "Tulsa,OK,USA",
    "Chicago,IL,USA",
    "Beijing,CN"
  ]

  def get_all_current_weather do
    # TODO
  end

  def get_current_weather(location) do
    url = "https://api.openweathermap.org/data/2.5/weather"
    api_key = Application.fetch_env!(:assist_a_bot, :weather_api_key)
    loc_query = URI.encode(location)

    HTTPoison.get("#{url}?q=#{loc_query}&appid=#{api_key}")
  end
end
