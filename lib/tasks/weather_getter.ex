defmodule Tasks.WeatherGetter do
  @locations [
    "Tulsa,OK,USA",
    "Chicago,IL,USA",
    "Beijing,CN"
  ]

  def get_all_current_weather do
    @locations
      |> Enum.map(&Task.async(fn -> get_current_weather(&1) end))
      |> Enum.map(&Task.await/1)
  end

  def get_current_weather(location) do
    url = "https://api.openweathermap.org/data/2.5/weather"
    api_key = Application.fetch_env!(:assist_a_bot, :weather_api_key)
    loc_query = URI.encode(location)

    HTTPoison.get!("#{url}?q=#{loc_query}&appid=#{api_key}")
      |> response_to_map()
      |> extract_data(location)
  end

  defp response_to_map(response) do
    Poison.decode!(response.body)
  end

  defp extract_data(weather_data, location) do
    temp_k = weather_data["main"]["temp"]
    temp_feels_k = weather_data["main"]["feels_like"]
    temp_max_k = weather_data["main"]["temp_max"]
    temp_min_k = weather_data["main"]["temp_min"]
    weather_description = Enum.at(weather_data["weather"], 0)["description"]
    wind_k = weather_data["wind"]["deg"]
    wind_m_s = weather_data["wind"]["speed"]

    %{
      "location" => format_location(location),
      "description" => weather_description,

      "temp_c" => k_to_c(temp_k),
      "temp_feels_c" => k_to_c(temp_feels_k),
      "temp_max_c" => k_to_c(temp_max_k),
      "temp_min_c" => k_to_c(temp_min_k),
      "wind_c" => k_to_c(wind_k),
      "wind_kph" => ms_to_kph(wind_m_s),

      "temp_f" => k_to_f(temp_k),
      "temp_feels_f" => k_to_f(temp_feels_k),
      "temp_max_f" => k_to_f(temp_max_k),
      "temp_min_f" => k_to_f(temp_min_k),
      "wind_f" => k_to_f(wind_k),
      "wind_mph" => ms_to_mph(wind_m_s)
    }
  end

  defp format_location(location) do
    location
      |> String.replace(",", ", ")
      |> String.replace(", USA", "")
  end

  defp k_to_f(temp) do
    ( (temp * (9 / 5)) - 459.67 )
      |> round_to_string()
      |> Kernel.<>("°F")
  end

  defp k_to_c(temp) do
    (temp - 273.15)
      |> round_to_string()
      |> Kernel.<>("°C")
  end

  defp ms_to_kph(speed) do
    (speed * 3.6)
      |> round_to_string()
      |> Kernel.<>(" mph")
  end

  defp ms_to_mph(speed) do
    (speed * 2.24)
      |> round_to_string()
      |> Kernel.<>(" km/h")
  end

  defp round_to_string(float_val) do
    float_val
      |> Decimal.from_float()
      |> Decimal.round(2)
      |> Decimal.to_string(:normal)
  end

end
