defmodule BeerDispenser.Repo.Migrations.AddDebtToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :debts, :integer
    end

    flush()

    BeerDispenser.Accounts.User
    |> BeerDispenser.Repo.all()
    |> Enum.each(fn user ->
      debt = BeerDispenser.Balances.Debt.get_by(%{user_id: user.id})

      user
      |> BeerDispenser.Accounts.User.changeset(%{debts: debt.amount})
      |> BeerDispenser.Repo.update!()
    end)
  end
end
