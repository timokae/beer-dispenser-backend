defmodule BeerDispenserWeb.AdminPriceController do
  use BeerDispenserWeb, :controller

  require Ecto.Query

  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Admin}

  plug :admin_check

  def index(conn, _params) do
    prices = Admin.all_prices()
    # changeset = Admin.Price.changeset(List.first(prices), %{})

    render(conn, "index.html", prices: prices)
  end

  def edit(conn, %{"id" => id}) do
    price = Admin.Price.get(id)
    changeset = Admin.Price.changeset(price, %{})

    render(conn, "edit.html", price: price, changeset: changeset)
  end

  def update(conn, %{"id" => id, "price" => price_params}) do
    price = Admin.Price.get(id)

    case Admin.Price.update(price, price_params) do
      {:ok, _price} ->
        conn
        |> put_flash(:info, "Settings saved")
        |> redirect(to: Routes.admin_price_path(conn, :index))

      {:error, changeset} ->
        conn
        |> render("edit.html", price: price, changeset: changeset)
    end
  end

  def new(conn, _params) do
    changeset = Admin.Price.changeset(%Admin.Price{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"price" => price_params}) do
    case Admin.Price.create(price_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Price saved")
        |> redirect(to: Routes.admin_price_path(conn, :index))

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    price = Admin.Price.get(id)

    case Admin.Price.delete(price) do
      {:ok, _} ->
        redirect(conn, to: Routes.admin_price_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not delete price")
        |> redirect(to: Routes.admin_price_path(conn, :index))
    end
  end
end
