defmodule BeerDispenser.ChipStore do
  use Agent

  require Logger

  def start_link(_) do
    Logger.debug("ChipStore started")

    Agent.start_link(
      fn -> nil end,
      name: __MODULE__
    )
  end

  def remove_old_id do
    now = Timex.now("Europe/Berlin")

    with %{timestamp: t} = chip <- Agent.get(__MODULE__, & &1),
         diff <- Timex.diff(now, t, :minutes),
         true <- Kernel.<(diff, 5) do
      Agent.update(__MODULE__, fn _ -> chip end)
    else
      _ ->
        Agent.update(__MODULE__, fn _ -> nil end)
    end
  end

  def get do
    Agent.get_and_update(__MODULE__, fn state ->
      case state do
        %{id: id, registered: registered} ->
          {{id, registered}, nil}

        _ ->
          {nil, nil}
      end
    end)
  end

  def put(id, registered) do
    chip = %{id: id, registered: registered, timestamp: Timex.now("Europe/Berlin")}

    Agent.update(__MODULE__, fn _ -> chip end)
  end

  def all do
    Agent.get(__MODULE__, & &1)
  end
end
