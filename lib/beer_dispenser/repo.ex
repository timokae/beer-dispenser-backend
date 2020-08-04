defmodule BeerDispenser.Repo do
  use Ecto.Repo,
    otp_app: :beer_dispenser,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    {:ok, config}
  end
end
