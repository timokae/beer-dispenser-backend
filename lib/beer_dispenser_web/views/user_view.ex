defmodule BeerDispenserWeb.UserView do
  use BeerDispenserWeb, :view

  def invoice_status(status) do
    case status do
      0 ->
        "Pending"

      1 ->
        "Paid"
    end
  end

  def status_class(status) do
    case status do
      0 ->
        "yellow"

      1 ->
        "green"
    end
  end
end
