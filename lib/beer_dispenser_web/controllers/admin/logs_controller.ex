defmodule BeerDispenserWeb.AdminLogsController do
  require Ecto.Query

  use BeerDispenserWeb, :controller

  import BeerDispenserWeb.Authorize

  plug :admin_check when action in [:index]

  def index(conn, _params) do
    query =
      "SELECT date(inserted_at), count(inserted_at) as total_count FROM logs GROUP BY date(inserted_at) ORDER BY date desc"

    result = Ecto.Adapters.SQL.query!(BeerDispenser.Repo, query)

    render(conn, "index.html", rows: Map.get(result, :rows, []))
  end
end
