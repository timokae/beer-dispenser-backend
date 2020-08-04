defmodule BeerDispenserWeb.Auth.Login do
  @moduledoc """
  Custom login module that checks if the user is confirmed before
  allowing the user to log in.
  """

  use Phauxth.Login.Base

  alias BeerDispenser.Accounts

  @impl true
  def authenticate(%{"password" => password} = params, _, opts) do
    case Accounts.get_by(params) do
      nil ->
        {:error, "no user found"}

      # %{confirmed_at: nil} -> {:error, "account unconfirmed"}
      user ->
        if Accounts.user_is_activated?(user) do
          Argon2.check_pass(user, password, opts)
        else
          BeerDispenserWeb.Email.send_activation_email(user)
          {:error, "User is not activated. A Activationlink is send to your email."}
        end
    end
  end
end
