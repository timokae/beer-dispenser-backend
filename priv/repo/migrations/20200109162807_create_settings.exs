defmodule BeerDispenser.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :entries, :map

      timestamps()
    end

  end
end
