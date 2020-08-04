defmodule BeerDispenserWeb.DebtsController do
  use BeerDispenserWeb, :controller

  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Accounts, Accounts.User, Admin, Balances, ChipStore}

  plug :user_check when action in [:charge]

  def charge(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    price = Admin.Price.get(id)

    case Balances.order(user, 1, price) do
      {:ok, user} ->
        Admin.Log.create()

        Phoenix.PubSub.broadcast!(
          BeerDispenser.PubSub,
          "#{BeerDispenser.Accounts.User}_#{user.id}",
          user.debts
        )

        conn
        |> put_flash(:charged, "")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        msg =
          changeset
          |> changeset_errors()
          |> Enum.join("\n")

        conn
        |> put_flash(:error, msg)
        |> redirect(to: "/")
    end
  end

  @doc """
  All errors in the changeset are converted to a list of string represention

  ## Example
  ```[amount: {"is invalid", [type: :integer, validation: :cast]}]```
  is converted to
  ["Amount is invalid"]
  """
  defp changeset_errors(%Ecto.Changeset{errors: errors}) do
    Enum.map(errors, fn {key, {reason, _}} ->
      key
      |> Atom.to_string()
      |> String.capitalize()
      |> Kernel.<>(" ")
      |> Kernel.<>(reason)
    end)
  end

  def charge_api(conn, %{"chip_id" => id}) do
    price = Admin.Price.get_by(%{name: "Beer"})

    with %User{} = user <- Accounts.get_by(%{"chip_id" => id}),
         {:ok, user} <- Balances.order(user, 1, price) do
      Admin.Log.create()
      ChipStore.put(id, true)

      Phoenix.PubSub.broadcast!(
        BeerDispenser.PubSub,
        "#{BeerDispenser.Accounts.User}_#{user.id}",
        user.debts
      )

      conn
      |> put_status(:ok)
      |> json(%{})
    else
      # Accounts.get_by
      nil ->
        ChipStore.put(id, false)

        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> json(changeset_errors(changeset))

      # Balances.order
      {:error, msg} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: msg})
    end
  end
end
