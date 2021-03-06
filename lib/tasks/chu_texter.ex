defmodule Tasks.ChuTexter do

  import Application, only: [fetch_env!: 2]

  def send_message do
    twilio_account_sid = fetch_env!(:assist_a_bot, :twilio_account_sid)
    twilio_user = fetch_env!(:assist_a_bot, :twilio_user)
    twilio_pass = fetch_env!(:assist_a_bot, :twilio_pass)
    twilio_number = fetch_env!(:assist_a_bot, :twilio_number)
    phone = fetch_env!(:assist_a_bot, :chu_phone_number)
    messages = fetch_env!(:assist_a_bot, :chu_text_messages)
    message = Enum.random(messages)

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
