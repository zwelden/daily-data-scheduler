defmodule Tasks.Weather.WeatherGetter do

  import Application, only: [fetch_env!: 2]

  @email_template_path Path.expand("lib/tasks/weather/email_templates", File.cwd!)

  @locations [
    "Tulsa,OK,USA",
    "Chicago,IL,USA",
    "Beijing,CN"
  ]


  def get_all_current_weather do
    @locations
      |> Enum.map(&Task.async(fn -> get_current_weather(&1) end))
      |> Enum.map(&Task.await/1)
      |> render_email_template()
      |> send_email()
  end

  def get_current_weather(location) do
    url = "https://api.openweathermap.org/data/2.5/weather"
    api_key = Application.fetch_env!(:assist_a_bot, :weather_api_key)
    loc_query = URI.encode(location)

    HTTPoison.get!("#{url}?q=#{loc_query}&appid=#{api_key}")
      |> response_to_map()
      |> extract_data(location)
  end

  # def render_email_templates(weather_reports) do
  #   ["weather_email_plain.eex", "weather_email_html.eex"]
  #     |> Enum.map(&render_email_template(&1, weather_reports))
  # end

  def render_email_template(weather_reports) do
    email_footer_address = fetch_env!(:assist_a_bot, :email_footer_address)
    template = Path.join(@email_template_path, "weather_email_html.eex")

    EEx.eval_file(template, [weather_reports: weather_reports, email_footer_address: email_footer_address])
  end

  def send_email(template) do
    IO.inspect template
    send_in_blue_api_key = fetch_env!(:assist_a_bot, :send_in_blue_api_key)
    self_email_address = fetch_env!(:assist_a_bot, :self_email_address)
    sender_email_address = fetch_env!(:assist_a_bot, :sender_email_address)
    api_endpoint = "https://api.sendinblue.com/v3/smtp/email"

    body = %{
      sender: %{
         name: "Zach Welden",
         email: sender_email_address
      },
      to: [
         %{
            email: self_email_address,
            name: "Zach Welden"
         }
      ],
      subject: "Weather Report",
      htmlContent: template
    } |> Poison.encode!

    HTTPoison.post(
      api_endpoint,
      body,
      [{"Content-Type", "application/json"},
        {"api-key", send_in_blue_api_key},
        {"Accept", "Application/json"}])
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
    wind_deg = weather_data["wind"]["deg"]
    wind_m_s = weather_data["wind"]["speed"]

    %{
      "location" => format_location(location),
      "description" => weather_description,

      "temp_c" => k_to_c(temp_k),
      "temp_feels_c" => k_to_c(temp_feels_k),
      "temp_max_c" => k_to_c(temp_max_k),
      "temp_min_c" => k_to_c(temp_min_k),
      "wind_dir" => deg_to_dir(wind_deg),
      "wind_kph" => ms_to_kph(wind_m_s),

      "temp_f" => k_to_f(temp_k),
      "temp_feels_f" => k_to_f(temp_feels_k),
      "temp_max_f" => k_to_f(temp_max_k),
      "temp_min_f" => k_to_f(temp_min_k),
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
      |> Kernel.<>(" km/h")
  end

  defp ms_to_mph(speed) do
    (speed * 2.24)
      |> round_to_string()
      |> Kernel.<>(" mph")
  end

  defp deg_to_dir(deg) do
    case deg do
      d when 348.75 < d and d <= 11.25
        -> "N"
      d when 11.25 < d and d <= 33.75
        -> "NNE"
      d when 33.75 < d and d <= 56.25
        -> "NE"
      d when 56.25 < d and d <= 78.75
        -> "ENE"
      d when 78.75 < d and d <= 101.25
        -> "E"
      d when 101.25 < d and d <= 123.75
        -> "ESE"
      d when 123.75 < d and d <= 146.25
        -> "SE"
      d when 146.25 < d and d <= 168.75
        -> "SSE"
      d when 168.75 < d and d <= 191.25
        -> "S"
      d when 191.25 < d and d <= 213.75
        -> "SSW"
      d when 213.75 < d and d <= 236.25
        -> "SW"
      d when 236.25 < d and d <= 258.75
        -> "WSW"
      d when 258.75 < d and d <= 281.25
        -> "W"
      d when 281.25 < d and d <= 303.75
        -> "WNW"
      d when 303.75 < d and d <= 326.25
        -> "NW"
      d when 348.75 < d and d <= 348.75
        -> "NW"
    end
  end

  defp round_to_string(float_val) do
    float_val
      |> Decimal.from_float()
      |> Decimal.round(0)
      |> Decimal.to_string(:normal)
  end

end
