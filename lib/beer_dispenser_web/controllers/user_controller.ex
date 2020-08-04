defmodule BeerDispenserWeb.UserController do
  require Ecto.Query

  use BeerDispenserWeb, :controller

  import BeerDispenserWeb.Authorize

  alias Phauxth.Log
  alias BeerDispenser.{Accounts, Accounts.User, ChipStore}

  # the following plugs are defined in the controllers/authorize.ex file
  plug :admin_check when action in [:new, :create, :delete]
  plug :id_check when action in [:edit, :update, :delete]
  plug :user_check when action in [:index]

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    user =
      user
      |> BeerDispenser.Repo.preload(:invoices)

    render(conn, "show.html", user: user)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)

    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    case Accounts.update_user(user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def update_password(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    case Accounts.update_password(user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  # ---Self registration with a chip---

  def register(conn, _params) do
    case ChipStore.get() do
      nil ->
        conn
        |> put_flash(:error, "No key stored")
        |> redirect(to: Routes.session_path(conn, :new))

      {_, true} ->
        conn
        |> put_flash(:error, "No unregistered key stored")
        |> redirect(to: Routes.session_path(conn, :new))

      {id, false} ->
        changeset = Accounts.change_user(%User{chip_id: id})
        render(conn, "register.html", changeset: changeset)
    end
  end

  def create_by_chip(conn, %{"user" => user_params}) do
    standard_params = %{
      "password" => "dfskfsfsdfsdf",
      "activation_key" => Ecto.UUID.generate(),
      "role" => "user"
    }

    user = Map.merge(user_params, standard_params)

    case Accounts.create_user(user) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User created successfully. We sent you and activation email.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end

  # --- Activation methods ---

  def activate(conn, params) do
    with %User{} = user <- Accounts.get_by(%{"activation_key" => params["key"]}),
         false <- Accounts.user_is_activated?(user) do
      changeset = User.changeset(user, %{})
      render(conn, "activate.html", changeset: changeset, user: user)
    else
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: "/sessions/new")

      true ->
        conn
        |> put_flash(:error, "User already activated")
        |> redirect(to: "/sessions/new")
    end
  end

  def initial_update(conn, %{"user" => new_user}) do
    user = Accounts.get(new_user["id"])

    case Accounts.activate_user(user, new_user) do
      {:ok, _} ->
        redirect(conn, to: Routes.session_path(conn, :new))

      {:error, changeset} ->
        conn
        |> render("activate.html", changeset: changeset, user: user)
    end
  end
end
