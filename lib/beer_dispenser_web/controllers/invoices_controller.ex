defmodule BeerDispenserWeb.InvoicesController do
  use BeerDispenserWeb, :controller

  require Ecto.Query

  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Balances, Repo}

  plug :user_check when action in [:create, :update]

  def update(
        %Plug.Conn{assigns: %{current_user: user}} = conn,
        %{"id" => id_str, "status" => "1"}
      ) do
    with {id, ""} <- Integer.parse(id_str),
         {:ok, _} <- Balances.pay_invoice(user, id) do
      redirect(conn, to: Routes.user_path(conn, :index))
    else
      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: Routes.user_path(conn, :index))

      :error ->
        conn
        |> put_flash(:error, "Id of invoice is not be parsed")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  def update(conn, _params),
    do: redirect(conn, to: Routes.user_path(conn, :index))

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    case Balances.generate_invoice(user) do
      {:ok, _} ->
        redirect(conn, to: Routes.user_path(conn, :index))

      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: Routes.user_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  def pay_all(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    case Balances.pay_all_invoices(user) do
      {_, nil} ->
        redirect(conn, to: Routes.user_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Could not update all invoices.")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end
end
