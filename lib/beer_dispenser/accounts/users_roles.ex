defmodule BeerDispenser.Accounts.UsersRoles do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeerDispenser.Accounts.UsersRoles

  @primary_key false
  schema "users_roles" do
    belongs_to(:user, BeerDispenser.Accounts.User, primary_key: true)
    belongs_to(:role, BeerDispenser.Accounts.Role, primary_key: true)
  end

  @doc false
  def changeset(users_roles, attrs) do
    users_roles
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
    |> unique_constraint([:user, :role],
      name: :user_id_project_id_unique_index,
      message: "Already exists"
    )
  end

  def create(attrs) do
    %UsersRoles{}
    |> UsersRoles.changeset(attrs)
    |> BeerDispenser.Repo.insert()
  end
end
