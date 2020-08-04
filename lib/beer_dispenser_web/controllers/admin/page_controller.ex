defmodule BeerDispenserWeb.AdminPageController do
  require Ecto.Query

  use BeerDispenserWeb, :controller

  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Admin, ChipStore}

  plug :admin_check when action in [:index, :send_reminder]

  def index(conn, _params) do
    %Admin.Settings{id: settings_id} = Admin.settings_row()

    render(conn, "index.html", settings_id: settings_id, last_scan: ChipStore.all)
  end

  def send_reminder(conn, _params) do
    BeerDispenser.InvoiceGenerator.send_emails()

    conn
    |> put_flash(:info, "Sent reminder to all users")
    |> redirect(to: Routes.admin_user_path(conn, :index))
  end
end
