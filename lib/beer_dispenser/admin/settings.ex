defmodule BeerDispenser.Admin.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeerDispenser.Repo

  schema "settings" do
    field :entries, :map

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:entries])
    |> validate_required([:entries])
  end

  def update(setting, attrs) do
    setting
    |> changeset(attrs)
    |> Repo.update()
  end
end
