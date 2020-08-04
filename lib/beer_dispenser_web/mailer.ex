defmodule BeerDispenserWeb.Mailer do
  use Bamboo.Mailer, otp_app: :beer_dispenser
  import Bamboo.Email

  alias BeerDispenser.{Accounts.User, Admin}
  alias BeerDispenserWeb.Helper

  @sender "..."
  # @host Application.get_env(:beer_dispenser, BeerDispenserWeb.Endpoint)[:http][:host]
  def activation_email(%User{} = user) do
    new_email(
      to: user.email,
      from: @sender,
      subject: "Account Activation",
      text_body: """
      Hi #{user.name},
      click the following link to activate your account.
      Klicke einfach auf den folgenden Link:
      http://#{host()}/activate/#{user.activation_key}
      """,
      html_body: """
      <h1>Hi #{user.name},</h1>
      click the following link to activate your account.
      <a href="http://#{host()}/activate/#{user.activation_key}">Activate</a>
      """
    )
  end

  def invoice_email(%User{} = user, amount) do
    link = "https://theke.9e.network/users"
    new_email(
      to: user.email,
      from: @sender,
      subject: "9Beers::Reminder - New invoice for you",
      text_body: """
      Hi #{user.name},
      there is a new invoice for you.

      Amount: #{Helper.currency_format(amount)}

      Pay with Paypal: #{link}
      """,
      html_body: """
      <p>
        Hi #{user.name},<br>
        there is a new invoice for you.<br/>
        Amount: <strong>#{Helper.currency_format(amount)}</strong>
      </p>
      <a href="#{link}">Pay with Paypal</a>
      """
    )
  end

  def paypal_confirmation_email(%User{} = user) do
    new_email(
      to: user.email,
      from: @sender,
      subject: "9Beers::Reminder - Confirm your payment",
      text_body: """
      Hi #{user.name},
      you just clicked on the "Pay with PayPal"-Button.

      Please remember to confirm your payment by clicking on the I have paid link.

      Thanks! :)
      """,
      html_body: """
      <p>
        Hi #{user.name},<br>
        you just clicked on the "Pay with PayPal"-Button.<br/>
        Please remember to confirm your payment by clicking on the "I've paid"-Button.<br/>
        <br/>
        Thanks! 🙂
      </p>
      """
    )
  end

  defp host do
    host = Application.get_env(:beer_dispenser, BeerDispenserWeb.Endpoint)[:url][:host]
    port = Application.get_env(:beer_dispenser, BeerDispenserWeb.Endpoint)[:url][:port]

    case Mix.env() do
      :prod ->
        "#{host}"

      _ ->
        "#{host}:#{port}"
    end
  end
end
