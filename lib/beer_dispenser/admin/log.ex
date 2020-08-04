defmodule BeerDispenser.Admin.Log do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeerDispenser.{Admin.Log, Repo}

  schema "logs" do
    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [])
    |> validate_required([])
  end

  def create() do
    %Log{}
    |> changeset(%{})
    |> Repo.insert()
  end
end
