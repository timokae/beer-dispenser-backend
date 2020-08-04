defmodule BeerDispenserWeb.AdminUserController do
  use BeerDispenserWeb, :controller

  require Ecto.Query

  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Accounts, Balances}

  # the following plugs are defined in the controllers/authorize.ex file
  plug :admin_check when action in [:index, :new, :create, :delete, :deposit_form, :deposit]
  plug :super_admin_check when action in [:debt]

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _params) do
    users =
      Accounts.list_users()
      |> Enum.map(fn user -> BeerDispenser.Repo.preload(user, :invoices) end)

    render(conn, "index.html", current_user: current_user, users: users)
  end

  def edit(conn, params) do
    user = Accounts.get(params["id"])
    changeset = Accounts.User.changeset(user, %{})

    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def new(conn, _) do
    changeset = Accounts.User.changeset(%Accounts.User{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params =
      user_params
      |> Map.put("password", "dhflakdhfskf")
      |> Map.put("activation_key", Ecto.UUID.generate())

    case Accounts.create_user(user_params) do
      {:ok, _} ->
        redirect(conn, to: Routes.admin_user_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"user" => user_params, "id" => id}) do
    user = Accounts.get(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.admin_user_path(conn, :edit, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, params) do
    user = Accounts.get(params["id"])

    case Accounts.delete_user(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: Routes.admin_user_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to delete user.")
        |> redirect(to: Routes.admin_user_path(conn, :edit, user))
    end
  end

  def deposit_form(conn, params) do
    IO.inspect(params)
    user = Accounts.get(params["admin_user_id"])

    render(conn, "deposit.html", user: user)
  end

  def deposit(conn, %{"user_id" => user_id, "amount" => amount}) do
    user = Accounts.get(user_id)

    with {amount, ""} <- Integer.parse(amount),
         {:ok, _} <- Balances.deposit_money(user, amount) do
      conn
      |> put_flash(:info, "The money was deposited")
      |> redirect(to: Routes.admin_user_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> render("deposit.html", user: user)
    end
  end

  def debts(conn, _params) do
    users =
      Accounts.list_users()
      |> Stream.map(fn user -> BeerDispenser.Repo.preload(user, :invoices) end)
      |> Enum.map(fn user ->
        sum = user.debts + Enum.reduce(user.invoices, 0, fn i, acc -> i.amount + acc end)
        %{name: user.name, debts: sum}
      end)

    render(conn, "debts.html", users: users)
  end
end
