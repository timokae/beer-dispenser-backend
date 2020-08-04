defmodule BeerDispenserWeb.DonationController do
  use BeerDispenserWeb, :controller
  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Admin, Balances, Balances.Debt, Balances.Donation}
  alias BeerDispenserWeb.Helper

  plug :user_check when action in [:new, :create]

  def new(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    changeset = Donation.changeset(%Donation{}, %{})
    render_form(conn, user, changeset)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"donation" => donation_attrs}) do
    case Balances.create_donation(user, donation_attrs) do
      {:ok, _} ->
        redirect(conn, to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{data: %Debt{}}} ->
        conn
        |> put_flash(:error, "Error while charging user")
        |> render(user, Donation.changeset(%Donation{}, %{}))

      {:error, changeset} ->
        render_form(conn, user, changeset)
    end
  end

  defp render_form(conn, user, changeset) do
    prices = Admin.all_prices()

    beer_id =
      Enum.find(prices, fn price -> price.name == "Beer" end)
      |> Map.get(:id)

    options =
      Enum.map(prices, fn price ->
        [
          key: "#{price.name} - #{Helper.currency_format(price.amount)}",
          value: price.id,
          selected: price.id == beer_id
        ]
      end)

    render(conn, "new.html", changeset: changeset, options: options, user: user, beer_id: beer_id)
  end
end
