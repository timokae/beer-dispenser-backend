# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

alias BeerDispenser.{Accounts.User, Admin.Price, Admin.Settings, Repo}

{:ok, _price} = Price.create(%{amount: 100, name: "Beer"})

%Settings{}
|> Settings.changeset(%{
  entries: %{
    "invoice_threshold" => "500",
    "keg_size" => "60",
    "paypal_url" => "..."
  }
})
|> Repo.insert()

# !!! To be able to login withg the user, activate it first on /activate/admin_activate
# user_role = Repo.get_by(BeerDispenser.Accounts.Role, name: "user")
# admin_role = Repo.get_by(BeerDispenser.Accounts.Role, name: "admin")
# super_role = Repo.get_by(BeerDispenser.Accounts.Role, name: "superadmin")

# attrs = %{
#   email: "admin@test.com",
#   password: "",
#   chip_id: "123",
#   name: "AdminUser",
#   activation_key: "admin_activate"
# }

# User.create_changeset(%User{}, attrs, [user_role, admin_role, super_role])
# |> Repo.insert()
