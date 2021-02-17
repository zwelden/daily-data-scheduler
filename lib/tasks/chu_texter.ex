defmodule Tasks.ChuTexter do

  @messages [
    "Chu Chu, you're the cutest!",
    "Chu, you are the best mom!",
    "Chu, what would I do without you!",
    "You have the most beautiful smile cutie Chu!",
    "楚楚我爱你！",
    "你太漂亮了！",
    "Stinky Chu!!"
  ]

  def send_message do
    twilio_account_sid = Application.fetch_env!(:assist_a_bot, :twilio_account_sid)
    twilio_user = Application.fetch_env!(:assist_a_bot, :twilio_user)
    twilio_pass = Application.fetch_env!(:assist_a_bot, :twilio_pass)
    twilio_number = Application.fetch_env!(:assist_a_bot, :twilio_number)
    phone = Application.fetch_env!(:assist_a_bot, :chu_phone_number)

    message = Enum.random(@messages)

    credentials = "#{twilio_user}:#{twilio_pass}" |> Base.encode64()
    body = {:form, Body: message, From: twilio_number, To: phone}

    HTTPoison.post(
      "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid}/Messages.json",
      body,
      [{"Content-Type", "application/x-www-form-urlencoded"},
        {"Authorization", "Basic #{credentials}"},
        {"Accept", "Application/json; Charset=utf-8"}])
  end

end