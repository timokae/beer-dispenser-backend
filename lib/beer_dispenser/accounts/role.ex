defmodule BeerDispenser.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeerDispenser.Accounts.Role

  schema "roles" do
    field :name, :string

    many_to_many(:users, BeerDispenser.Accounts.User, join_through: "users_roles")

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def create_role(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> BeerDispenser.Repo.insert()
  end
end
