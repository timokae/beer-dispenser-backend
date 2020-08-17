defmodule BeerDispenser.Balances do
  @moduledoc """
  The Balances context
  """
  require Ecto.Query

  alias BeerDispenser.{
    Accounts.User,
    Admin.Price,
    Balances,
    Balances.Donation,
    Balances.Invoice,
    Repo
  }

  @doc """
  Decreases number of donations or increases the debt amount of the user

  When donations for the requested price exist, no charges are made. Instead the amount of donations is decreased.
  Otherwise the user will be charges the given price times the amount of the ordered beverages.
  """
  @spec order(User.t(), integer(), Price.t()) ::
          {:error, String.t()} | {:ok, Donation.t()} | {:ok, Debt.t()}
  def order(%User{confirmed_at: nil}, _amount, _price),
    do: {:error, "User not activated"}

  def order(%User{role: "testuser"} = user, _amount, _price) do
    {:ok, user}
  end

  def order(user, amount, price) do
    case first_donation(price) do
      %Donation{} = donation ->
        Donation.decrease_amount(donation, amount)

        {:ok, user}

      _ ->
        charge(user, amount, price)
    end
  end

  # --- Debt ---

  @doc """
  Increases the debts of the user with the given price times the amount
  """
  @spec charge(User.t(), integer(), Price.t()) ::
          {:ok, Debt.t()} | {:error, Ecto.Changeset.t()}
  def charge(user, amount, price) do
    addional_debt = amount * price.amount

    user
    |> User.changeset(%{debts: user.debts - addional_debt})
    |> Repo.update()
  end

  @doc """
  Sets the debts of a user to zero
  """
  @spec reset_debt(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def reset_debt(user) do
    user
    |> User.changeset(%{debts: 0})
    |> Repo.update()
  end

  @doc """
  Decreases the debts of the user with the given amount
  """
  def deposit_money(user, amount) do
    user
    |> User.changeset(%{debts: user.debts + amount})
    |> Repo.update()
  end

  # --- Invoice ---
  @doc """
  If the the invoices is created the debt of the user is resetted.
  When is debt is zero, an error is returned
  """
  @spec generate_invoice(User.t()) :: {:ok, Invoice.t()} | {:error, Ecto.Changeset.t()}
  def generate_invoice(user) do
    user = Repo.preload(user, :invoices)

    if user.debts < 0 do
      create_new_invoice(user)
    else
      {:error, "You don't have any debts"}
    end
  end

  defp create_new_invoice(user) do
    invoice = %{
      amount: user.debts,
      status: 0,
      key: Ecto.UUID.generate()
    }

    with {:ok, invoice} <- Invoice.create(user, invoice),
         {:ok, _} <- reset_debt(user) do
      {:ok, invoice}
    else
      error ->
        error
    end
  end

  defp update_existing_invoice(user) do
    last_invoice = List.last(user.invoices)
    attrs = %{amount: last_invoice.amount + user.debts}

    with {:ok, invoice} <- Invoice.update(last_invoice, attrs),
         {:ok, _} <- reset_debt(user) do
      {:ok, invoice}
    else
      error ->
        error
    end
  end

  @doc """
  Marks an invoice as paid.

  When an invoice is marked as paid, the user field of the invoice is cleared.
  """
  @spec pay_invoice(User.t(), integer()) ::
          {:ok, Invoice.t()} | {:error, String.t()}
  def pay_invoice(user, invoice_id) do
    with {:ok, invoice} <- invoice_of_user(user, invoice_id),
         {:ok, invoice} <- Invoice.update(invoice, %{status: "1", user_id: nil}) do
      {:ok, invoice}
    else
      {:error, _changeset} ->
        {:error, "Error while updating invoice"}

      {:not_found, msg} ->
        {:error, msg}
    end
  end

  @doc """
  Marks all pending invoices of a user as paid.

  When an invoice is marked as paid, the user field of the invoice is cleared.
  """
  def pay_all_invoices(user) do
    query =
      Ecto.Query.from(i in Invoice,
        where:
          i.status == 0 and
            i.user_id == ^user.id
      )

    BeerDispenser.Repo.update_all(query, set: [status: 1, user_id: nil])
  end

  @spec invoice_of_user(User.t(), integer()) :: {:ok, Invoice.t()} | {:error, String.t()}
  defp invoice_of_user(user, invoice_id) do
    with %Invoice{} = invoice <- Invoice.get(invoice_id),
         true <- invoice.user_id == user.id do
      {:ok, invoice}
    else
      _ ->
        {:error, "Invoice for user not found"}
    end
  end

  # --- Donation ---
  @doc """
  Creates a donation for the user

  When something went wrong, it either returns a changeset of BeerDispenser.Balances.Debt or BeerDispenser.Balances.Invoice
  """
  @spec create_donation(User.t(), map()) ::
          {:ok, Donation.t()} | {:error, Ecto.Changeset.t()}
  def create_donation(user, donation_attrs) do
    with {:ok, donation} <- Donation.create(user, donation_attrs),
         %Donation{} = donation <- Repo.preload(donation, :price),
         {:ok, _} <- Balances.charge(user, donation.amount, donation.price) do
      {:ok, donation}
    else
      error ->
        error
    end
  end

  @doc """
  Returns the first (oldest) donation for a price.
  """
  @spec first_donation(Price.t()) :: Price.t() | nil
  def first_donation(price) do
    price
    |> Repo.preload(:donations)
    |> Map.get(:donations)
    |> Enum.sort_by(fn d -> d.inserted_at end)
    |> List.first()
  end
end
