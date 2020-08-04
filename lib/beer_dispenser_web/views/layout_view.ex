defmodule BeerDispenserWeb.LayoutView do
  use BeerDispenserWeb, :view

  def current_session(conn) do
    Plug.Conn.get_session(conn, :phauxth_session_id)
  end
end
