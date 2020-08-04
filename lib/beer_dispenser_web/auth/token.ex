defmodule BeerDispenserWeb.Auth.Token do
  @moduledoc """
  Custom token implementation using Phauxth.Token behaviour and Phoenix Token.
  """

  @behaviour Phauxth.Token

  alias BeerDispenserWeb.Endpoint
  alias Phoenix.Token

  @token_salt "WWryOUv7"
  @max_age 1_209_600

  @impl true
  def sign(data, opts \\ []) do
    opts = Keyword.put(opts, :max_age, @max_age)

    Token.sign(Endpoint, @token_salt, data, opts)
  end

  @impl true
  def verify(token, opts \\ []) do
    opts = Keyword.put(opts, :max_age, @max_age)

    Token.verify(Endpoint, @token_salt, token, opts)
  end
end
