defmodule BeerDispenser.Balances.Debt do
  use Ecto.Schema
  import Ecto.Changeset

  require Ecto.Query

  alias BeerDispenser.{Balances.Debt, Repo}

  schema "debts" do
    field :amount, :integer

    belongs_to(:user, BeerDispenser.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(debt, attrs) do
    debt
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end

  def get_by(%{user_id: id}) do
    Debt
    |> Ecto.Query.where(user_id: ^id)
    |> Repo.one()
  end
end
