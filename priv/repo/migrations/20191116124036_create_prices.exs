defmodule BeerDispenser.Repo.Migrations.CreatePrice do
  use Ecto.Migration

  def change do
    create table(:prices) do
      add :amount, :integer
      add :name, :string

      timestamps()
    end
  end
end
