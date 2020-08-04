defmodule BeerDispenser.Repo.Migrations.AddActivationToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :activation_key, :string
    end
  end
end
