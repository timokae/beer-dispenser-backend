defmodule BeerDispenser.InvoiceGenerator do
  use Quantum.Scheduler,
    otp_app: :beer_dispenser

  require Ecto.Query
  require Logger

  alias BeerDispenser.{Accounts, Admin, Balances, Repo}
  alias BeerDispenserWeb.Email

  def notify_users do
    Logger.info("[InvoiceGenerator] notifying at #{Timex.now("Europe/Berlin")}")
    generate_invoices()
    send_emails()
  end

  @doc """
  Creates/Updates invoices for all users
  """
  def generate_invoices do
    {threshold, _} = Admin.setting("invoice_threshold") |> Integer.parse()

    Accounts.User
    |> Ecto.Query.where([user], user.debts <= ^threshold * -1)
    |> Repo.all()
    |> Enum.each(fn user -> Balances.generate_invoice(user) end)
  end

  @doc """
  When a user has an pending invoice, an reminder email is send
  """
  def send_emails do
    # {threshold, _} = Admin.setting("invoice_threshold") |> Integer.parse()

    Accounts.User
    |> Repo.all()
    |> Repo.preload(:invoices)
    |> Enum.filter(fn user -> length(user.invoices) > 0 end)
    |> Enum.each(&send_invoice_to_user/1)

    # Balances.Invoice
    # |> Ecto.Query.where([invoice], not is_nil(invoice.user_id))
    # |> Repo.all()
    # |> Repo.preload(:user)
    # |> Enum.each(&send_invoice_to_user/1)
  end

  # defp send_invoice_to_user(%Balances.Invoice{user: user, amount: amount}) do
  #   Email.send_invoice_email(user, amount)
  # end

  defp send_invoice_to_user(user) do
    amount =
      user
      |> Map.get(:invoices)
      |> Enum.map(&Map.get(&1, :amount))
      |> Enum.sum()

    Email.send_invoice_email(user, amount)
  end
end
