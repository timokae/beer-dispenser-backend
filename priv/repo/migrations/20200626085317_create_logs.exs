defmodule BeerDispenser.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do

      timestamps()
    end

  end
end
