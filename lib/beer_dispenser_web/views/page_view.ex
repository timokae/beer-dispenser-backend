defmodule BeerDispenserWeb.PageView do
  use BeerDispenserWeb, :view

  alias BeerDispenser.{Repo}

  def donors_names(donations) do
    donations = Repo.preload(donations, :user)

    case length(donations) do
      1 ->
        donation = List.first(donations)
        donation.user.name

      _ ->
        [h | t] = donations

        Enum.map(t, fn donation -> donation.user.name end)
        |> Enum.join(",")
        |> Kernel.<>(" and #{h.user.name}")
    end
  end

  def beverages_left(donations) do
    donations
    |> Enum.reduce(0, fn donation, acc -> acc + donation.amount end)
  end

  def donation_messages(donations) do
    donations
    |> Enum.map(fn d -> %{name: d.user.name, message: d.message} end)
    |> Enum.filter(&contains_text/1)
  end

  defp contains_text(%{message: message}) do
    not is_nil(message) && String.length(message) > 0
  end
end
