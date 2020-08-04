defmodule BeerDispenser.SessionRemover do
  use Quantum.Scheduler,
    otp_app: :beer_dispenser

  require Ecto.Query
  require Logger

  alias BeerDispenser.{Repo, Sessions.Session}
  alias Ecto.Query

  def perform do
    now = DateTime.utc_now()
    Repo.delete_all(Query.from(s in Session, where: s.expires_at < ^now))
    Logger.info("Old Sessions removed")
  end
end
