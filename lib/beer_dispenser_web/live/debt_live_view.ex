defmodule BeerDispenserWeb.Live.DebtLiveView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <p class="debt <%= @animation_class %>"><%= BeerDispenserWeb.Helper.currency_format(@debt_amount) %></p>
    """
  end

  def mount(%{"debt_amount" => debt_amount, "id" => id, "animation_class" => class}, socket) do
    Phoenix.PubSub.subscribe(BeerDispenser.PubSub, "#{BeerDispenser.Accounts.User}_#{id}")

    socket =
      socket
      |> assign(:debt_amount, debt_amount)
      |> assign(:animation_class, "")

    {:ok, socket}
  end

  def handle_info(debt_amount, socket) do
    debt_animation =
      case socket do
        %{assigns: %{animation_class: "debt-animation"}} ->
          "debt-animation-2"

        _ ->
          "debt-animation"
      end

    socket =
      socket
      |> assign(:debt_amount, debt_amount)
      |> assign(:animation_class, debt_animation)

    {:noreply, socket}
  end
end
