defmodule BeerDispenser.Balances.Donation do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeerDispenser.Repo

  schema "donations" do
    field :amount, :integer
    field :message, :string
    belongs_to(:price, BeerDispenser.Admin.Price)
    belongs_to(:user, BeerDispenser.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(donation, attrs) do
    donation
    |> cast(attrs, [:amount, :message, :price_id])
    |> validate_required([:amount, :price_id])
    |> validate_number(:amount, greater_than: 0)
  end

  def changeset_amount(donation, attrs) do
    donation
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than: 0)
  end

  def create(user, attrs) do
    user
    |> Ecto.build_assoc(:donations)
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(donation, attrs) do
    donation
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(donation) do
    donation
    |> Repo.delete()
  end

  def decrease_amount(donation, n) do
    amount_left = donation.amount - n

    cond do
      amount_left < 0 ->
        {:error, "Not enough left"}

      amount_left == 0 ->
        delete(donation)

      amount_left > 0 ->
        update(donation, %{amount: amount_left})
    end
  end
end
