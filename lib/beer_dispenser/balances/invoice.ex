defmodule BeerDispenser.Balances.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  require Ecto.Query

  alias BeerDispenser.{Balances.Invoice, Repo}

  # status => 0: pending
  # status => 1: paid

  schema "invoices" do
    field :amount, :integer
    field :key, :string
    field :status, :integer
    belongs_to(:user, BeerDispenser.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(invoices, attrs) do
    invoices
    |> cast(attrs, [:amount, :status, :key, :user_id])
    |> validate_required([:amount, :status, :key])
  end

  def get(id) do
    Invoice
    |> Ecto.Query.where(id: ^id)
    |> Repo.one()
  end

  def create(user, attrs) do
    user
    |> Ecto.build_assoc(:invoices)
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  def update(invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end
end
