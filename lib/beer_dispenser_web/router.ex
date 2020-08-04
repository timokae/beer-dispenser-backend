defmodule BeerDispenserWeb.Router do
  use BeerDispenserWeb, :router

  alias BeerDispenserWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate, max_age: 30 * 24 * 60 * 60
    plug Phauxth.Remember, create_session_func: &Auth.Utils.create_session/1
    plug :renew_rem_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BeerDispenserWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/forward", PageController, :forward

    resources "/users", UserController, except: [:show]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/password_resets", PasswordResetController, only: [:new, :create]

    get "/confirms", ConfirmController, :index
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update
    put "/users/:id/password_update", UserController, :update_password

    get "/register", UserController, :register
    post "/register", UserController, :create_by_chip
    get "/activate/:key", UserController, :activate
    put "/users/initial_update/:id", UserController, :initial_update

    post "/charge/:id", DebtsController, :charge

    post "/invoices/create", InvoicesController, :create
    post "/invoices/pay/:id", InvoicesController, :update
    post "/invoices/pay_all", InvoicesController, :pay_all

    resources "/donations", DonationController, only: [:new, :create]
  end

  scope "/admin", BeerDispenserWeb do
    pipe_through :browser

    get "/", AdminPageController, :index

    resources "/users", AdminUserController do
      get "/deposit_form", AdminUserController, :deposit_form, as: :deposit
      post "/deposit", AdminUserController, :deposit, as: :deposit
    end

    get "/user_debts", AdminUserController, :debts, as: :debts

    resources "/prices", AdminPriceController, except: [:show]
    resources "/statistics", AdminStatisticController, only: [:index, :show], param: "year"
    resources "/settings", AdminSettingController, only: [:edit, :update]
    resources "/logs", AdminLogsController, only: [:index]
    post "/send_reminder", AdminPageController, :send_reminder
  end

  scope "/api", BeerDispenserWeb do
    pipe_through :api

    post "/charge", DebtsController, :charge_api
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # should be same as in BeerDispenserWeb.Auth.Token
  @max_age 1_209_600
  defp renew_rem_token(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, _) do
    Phauxth.Remember.add_rem_cookie(conn, user_id, @max_age)
  end

  defp renew_rem_token(conn, _), do: conn
end
