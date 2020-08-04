defmodule BeerDispenser.Repo.Migrations.TransferRoles do
  use Ecto.Migration

  def change do
    alter table(:users_roles) do
      remove :inserted_at
      remove :updated_at
    end

    flush()

    # Create testuser role
    {:ok, testuser} = BeerDispenser.Accounts.Role.create_role(%{name: "testuser"})
    {:ok, normaluser} = BeerDispenser.Accounts.Role.create_role(%{name: "user"})
    {:ok, admin} = BeerDispenser.Accounts.Role.create_role(%{name: "admin"})
    {:ok, superadmin} = BeerDispenser.Accounts.Role.create_role(%{name: "superadmin"})

    BeerDispenser.Accounts.User
    |> BeerDispenser.Repo.all()
    |> Enum.each(fn user ->
      user = BeerDispenser.Repo.preload(user, :roles)

      case user.role do
        "user" ->
          user
          |> BeerDispenser.Accounts.User.role_changeset([normaluser])
          |> BeerDispenser.Repo.update!()

        "admin" ->
          user
          |> BeerDispenser.Accounts.User.role_changeset([normaluser, admin])
          |> BeerDispenser.Repo.update!()

        "testuser" ->
          user
          |> BeerDispenser.Accounts.User.role_changeset([testuser])
          |> BeerDispenser.Repo.update!()
      end
    end)
  end
end
