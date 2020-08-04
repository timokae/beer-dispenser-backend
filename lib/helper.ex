defmodule BeerDispenserWeb.Helper do
  def to_euro(value) do
    value
    |> Kernel./(100)
    |> Float.round(2)
  end

  def currency_format(nil), do: currency_format(0)

  def currency_format(value) do
    value
    |> to_euro()
    |> :erlang.float_to_binary(decimals: 2)
    |> Kernel.<>("€")
  end

  def paypal_link(amount),
    do: "#{BeerDispenser.Admin.setting("paypal_url")}/#{to_euro(amount * -1)}EUR"

  def sum_of_invoices(invoices) do
    invoices
    |> Enum.map(&Map.get(&1, :amount))
    |> Enum.sum()
  end

  def format_date(date), do: Timex.format!(date, "%d.%m.%Y", :strftime)
end
