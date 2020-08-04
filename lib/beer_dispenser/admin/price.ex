defmodule BeerDispenser.Admin.Price do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeerDispenser.{Admin.Price, Repo}

  schema "prices" do
    field :amount, :integer
    field :name, :string
    has_many :donations, BeerDispenser.Balances.Donation, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(price, attrs) do
    price
    |> cast(attrs, [:amount, :name])
    |> validate_required([:amount, :name])
  end

  def get(id) do
    Price
    |> Repo.get(id)
  end

  def get_by(%{name: name}) do
    Price
    |> Repo.get_by(name: name)
  end

  def create(attrs) do
    %Price{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(price, attrs) do
    price
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(price) do
    case price.name == "Beer" do
      true -> {:error, []}
      _ -> Repo.delete(price)
    end
  end
end
