defmodule BeerDispenser.Repo.Migrations.CreateDonations do
  use Ecto.Migration

  def change do
    create table(:donations) do
      add :amount, :integer
      add :message, :text
      add :price_id, references(:prices, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:donations, [:price_id])
    create index(:donations, [:user_id])
  end
end
