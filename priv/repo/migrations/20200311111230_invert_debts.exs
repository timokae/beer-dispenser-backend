defmodule BeerDispenser.Repo.Migrations.InvertDebts do
  use Ecto.Migration

  def change do
    BeerDispenser.Accounts.User
    |> BeerDispenser.Repo.all()
    |> Enum.each(fn user ->
      user
      |> BeerDispenser.Accounts.User.changeset(%{debts: user.debts * -1})
      |> BeerDispenser.Repo.update!()
    end)
  end
end
