defmodule BeerDispenser.Admin do
  @moduledoc """
  The Admin context
  """
  alias BeerDispenser.{Admin, Repo}

  require Ecto.Query

  # --- Price ---

  @doc """
  Returns all prices
  """
  def all_prices do
    Admin.Price
    |> Repo.all()
    |> Enum.sort_by(fn price -> price.name end)
  end

  @doc """
  Reurns all prices except the beer price
  """
  def prices_except_beer do
    Admin.Price
    |> Ecto.Query.where([price], price.name != "Beer")
    |> Repo.all()
  end

  @doc """
  Returns settings row from the database
  """
  def settings_row do
    Admin.Settings
    |> Ecto.Query.first()
    |> Repo.one()
  end

  @doc """
  Returns the settings map
  """
  @spec settings() :: map() | nil
  def settings do
    settings_row()
    |> Map.get(:entries, nil)
  end

  @doc """
  Return a specific setting

  ## Arguments
  - key: name of the setting to return
  """
  @spec setting(String.t()) :: String.t()
  def setting(key) do
    settings()
    |> Map.get(key, nil)
  end

  @doc """
  Creates or updates a setting
  """
  @spec put_setting(String.t(), any()) ::
          {:ok, BeerDispenser.Admin.Settings} | {:error, Ecto.Changeset.t()}
  def put_setting(key, value) do
    row = settings_row()

    new_settings =
      row
      |> Map.get(:entries)
      |> Map.put(key, value)

    row
    |> Admin.Settings.changeset(%{entries: new_settings})
    |> Repo.update()
  end
end
