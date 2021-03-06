defmodule BeerDispenserWeb.PasswordResetController do
  use BeerDispenserWeb, :controller

  alias BeerDispenser.Accounts
  alias BeerDispenserWeb.{Auth.Token, Email}
  alias Phauxth.Confirm.PassReset

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    if Accounts.create_password_reset(%{"email" => email}) do
      key = Token.sign(%{"email" => email})
      # Email.reset_request(email, Routes.password_reset_url(conn, :edit, key: key))
      Email.reset_request(email, Routes.password_reset_url(conn, :edit, key: key))
    end

    conn
    |> put_flash(:info, "Check your inbox for instructions on how to reset your password")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  def edit(conn, %{"key" => key}) do
    render(conn, "edit.html", key: key)
  end

  def edit(conn, _params) do
    render(conn, BeerDispenserWeb.ErrorView, "404.html")
  end

  def update(conn, %{"password_reset" => params}) do
    case PassReset.verify(params) do
      {:ok, user} ->
        user
        |> Accounts.update_password(params)
        |> update_password(conn, params)

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("edit.html", key: params["key"])
    end
  end

  defp update_password({:ok, user}, conn, _params) do
    Email.reset_success(user.email)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "Your password has been reset")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)

    conn
    |> put_flash(:error, message || "Invalid input")
    |> render("edit.html", key: params["key"])
  end
end
