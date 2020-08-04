defmodule BeerDispenserWeb.AdminStatisticController do
  use BeerDispenserWeb, :controller

  require Ecto.Query

  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Balances.Invoice, Repo}

  plug :admin_check when action in [:show]

  def show(conn, %{"year" => year}) do
    {year, _} = Integer.parse(year)
    date = Timex.now() |> Timex.set(year: year)

    start_of_year = Timex.beginning_of_year(date)
    end_of_year = Timex.end_of_year(date)

    invoice_query =
      Ecto.Query.from(i in Invoice,
        where:
          i.inserted_at >= ^start_of_year and
            i.inserted_at <= ^end_of_year and
            is_nil(i.user_id)
      )

    filled_buckets =
      invoice_query
      |> Repo.all()
      |> Enum.reduce(buckets(), &organize_by_month/2)

    render(conn, "show.html", buckets: filled_buckets, year: year)
  end

  def index(conn, _) do
    redirect(conn, to: Routes.admin_statistic_path(conn, :show, Timex.now().year))
  end

  defp organize_by_month(invoice, buckets) do
    month = Timex.to_date(invoice.inserted_at).month
    Map.update(buckets, month, invoice.amount, &(&1 + invoice.amount))
  end

  defp buckets do
    %{
      1 => 0,
      2 => 0,
      3 => 0,
      4 => 0,
      5 => 0,
      6 => 0,
      7 => 0,
      8 => 0,
      9 => 0,
      10 => 0,
      11 => 0,
      12 => 0
    }
  end
end
