defmodule BeerDispenser.Accounts.User do
  use Ecto.Schema

  require Ecto.Query

  import Ecto.Changeset

  alias BeerDispenser.{Accounts.Role, Accounts.Invoice, Balances.Donation, Sessions.Session}

  @type t :: %__MODULE__{
          id: integer,
          email: String.t(),
          password_hash: String.t(),
          confirmed_at: DateTime.t() | nil,
          reset_sent_at: DateTime.t() | nil,
          sessions: [Session.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          chip_id: String.t(),
          name: String.t(),
          activation_key: String.t(),
          role: String.t(),
          # roles: [Role.t()] | %Ecto.Association.NotLoaded{},
          invoices: [Invoice.t()] | %Ecto.Association.NotLoaded{}
        }

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, :utc_datetime
    field :reset_sent_at, :utc_datetime
    field :chip_id, :string, unique: true
    field :name, :string
    field :activation_key, :string
    field :role, :string
    field :debts, :integer, default: 0
    has_many :sessions, Session, on_delete: :delete_all
    has_many :invoices, BeerDispenser.Balances.Invoice, on_delete: :delete_all
    has_many :donations, BeerDispenser.Balances.Donation, on_delete: :nothing
    many_to_many(:roles, BeerDispenser.Accounts.Role, join_through: "users_roles")

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :chip_id, :name, :confirmed_at, :debts])
    |> validate_required([:email, :name, :chip_id])
    |> unique_email
  end

  def create_changeset(%__MODULE__{} = user, attrs, roles) do
    user
    |> cast(attrs, [:email, :password, :chip_id, :name, :activation_key, :debts])
    |> validate_required([:email, :password, :chip_id, :name])
    |> unique_email
    # |> validate_password(:password)
    |> put_pass_hash
    |> put_assoc(:roles, roles)
  end

  def role_changeset(%__MODULE__{} = user, roles) do
    user
    |> cast(%{}, [])
    |> put_assoc(:roles, roles)
  end

  def confirm_changeset(%__MODULE__{} = user, confirmed_at) do
    change(user, %{confirmed_at: confirmed_at})
  end

  def password_reset_changeset(%__MODULE__{} = user, reset_sent_at) do
    change(user, %{reset_sent_at: reset_sent_at})
  end

  def update_password_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_confirmation(:password, message: "Passwords does not match", required: true)
    # |> validate_password(:password)
    |> put_pass_hash()
    |> change(%{reset_sent_at: nil})
  end

  def has_role?(user, role_name) do
    role =
      BeerDispenser.Accounts.Role
      |> Ecto.Query.where([role], role.name == ^role_name)
      |> Ecto.Query.first()
      |> BeerDispenser.Repo.one!()

    user
    |> BeerDispenser.Repo.preload(:roles)
    |> Map.get(:roles, [])
    |> Enum.member?(role)
  end

  def highest_role(user) do
    roles =
      user
      |> BeerDispenser.Repo.preload(:roles)
      |> Map.get(:roles)
      |> Enum.map(fn role -> role.name end)

    cond do
      Enum.member?(roles, "superadmin") ->
        "SuperAdmin"

      Enum.member?(roles, "admin") ->
        "Admin"

      Enum.member?(roles, "user") ->
        "User"

      Enum.member?(roles, "testuser") ->
        "TestUser"

      true ->
        "Not found"
    end
  end

  defp unique_email(changeset) do
    changeset
    |> validate_format(
      :email,
      ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}$/
    )
    |> validate_length(:email, max: 255)
    |> unique_constraint(:email)
  end

  # If you are using Bcrypt or Pbkdf2, change Argon2 to Bcrypt or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  # defp validate_password(changeset, field, options \\ []) do
  #   validate_change(changeset, field, fn _, password ->
  #     case strong_password?(password) do
  #       {:ok, _} -> []
  #       {:error, msg} -> [{field, options[:message] || msg}]
  #     end
  #   end)
  # end

  # defp strong_password?(password) when byte_size(password) > 7 do
  #   {:ok, password}
  # end

  # defp strong_password?(_), do: {:error, "The password is too short"}
end
