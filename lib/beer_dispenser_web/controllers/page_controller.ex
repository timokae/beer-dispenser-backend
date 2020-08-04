defmodule BeerDispenserWeb.PageController do
  use BeerDispenserWeb, :controller

  import BeerDispenserWeb.Authorize

  require Ecto.Query

  alias BeerDispenser.{Accounts.User, Admin}

  plug :user_check when action in [:index, :forward]

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    user_query = Ecto.Query.from(u in User, select: [:name])

    beer =
      Admin.Price.get_by(%{name: "Beer"})
      |> BeerDispenser.Repo.preload(donations: [user: user_query])

    render(conn, "index.html", user: user, beer: beer)
  end

  def forward(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"url" => url}) do
    BeerDispenserWeb.Email.send_paypal_confirmation_email(user)
    redirect(conn, external: url)
  end
end
