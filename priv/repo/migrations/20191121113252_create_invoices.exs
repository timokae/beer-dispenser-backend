defmodule BeerDispenser.Repo.Migrations.CreateInvoice do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :amount, :integer
      add :status, :integer
      add :key, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:invoices, [:user_id])
  end
end
