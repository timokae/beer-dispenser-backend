defmodule BeerDispenserWeb.AdminSettingController do
  use BeerDispenserWeb, :controller

  require Ecto.Query

  import BeerDispenserWeb.Authorize

  alias BeerDispenser.{Admin}

  plug :admin_check when action in [:index]

  def edit(conn, _params) do
    %Admin.Settings{id: id, entries: entries} = Admin.settings_row()

    render(conn, "edit.html", id: id, entries: entries)
  end

  def update(conn, %{"entries" => entries}) do
    settings = Admin.settings_row()
    new_entries = Map.merge(settings.entries, entries)

    case Admin.Settings.update(settings, %{entries: new_entries}) do
      {:ok, settings} ->
        redirect(conn, to: Routes.admin_setting_path(conn, :edit, settings.id))

      _ ->
        conn
        |> put_flash(:error, "Failed to save settings")
        |> redirect(to: Routes.admin_setting_path(conn, :edit, settings.id))
    end
  end
end
