# BeerDispenser

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

# Installation
* Install asdf version manager
* Install `Erlang 22.0.4`
* Install `Elixir 1.9.0-otp-22`
* Install nvm
* Install latest node version
* Run `npm i` in `./assets`
* Install Postgres

# Deploy
* `docker-compose build && docker-compose push`
* Remote:
  * `systemctl stop theken.service`
  * `Repo pullen (ganz normal git pull auf master im beer-dispenser verzeichnis)`
  * `Docker images pullen (docker-compose pull)`
  * `systemctl start theken.service`

Add role to user

```elixir
user |> Ecto.Changeset.cast(%{}, []) |> Ecto.Changeset.put_assoc(:roles, [role | user.roles]) |> BeerDispenser.Repo.update
```
