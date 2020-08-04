defmodule BeerDispenser.Repo.Migrations.CreateDebts do
  use Ecto.Migration

  def change do
    create table(:debts) do
      add :amount, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:debts, [:user_id])
  end
end
