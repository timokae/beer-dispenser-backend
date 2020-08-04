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

# Tasks
* ~~Registrierungslink zur Accountaktivierung~~
* ~~Abrechnen implementieren~~
* ~~Rechnungen mit Id versehen~~
*  ~~Mail schicken bei Charge ohne Account~~
* ~~Admin backend~~
* ~~Gmail statt SendGrind benutzen~~
* ~~Role zu Admin User Page hinzufügen~~
* ~~Ausprobieren ob Docker noch funktioniert~~
* ~~Freibierfunktion (20Liter/Bier für alle anderen freischalten)~~
* ~~Neue User anlegen können~~
* ~~Alle Preise anzeigen und bestellbar machen~~
* ~~InvoiceGenerator triggert zu früh~~
* ~~Wenn Account nicht aktiviert abbrechen~~
* ~~Passwort statt Textfelder beim Profilbearbeiten~~
* ~~TestUser Role~~
* ~~Userlink ohne Id~~
* ~~Statistics aktuelle Jahr~~
* ~~Emails manuell triggern~~
* ~~Remember me~~
* ~~Aktuelles Guthaben unter Preis~~
* ~~Favicon~~
* ~~Mit Vorkasse bezahlen über Admin~~
* ~~Paypal in neuem Fenster und Email senden~~
* ~~Email anpassen~~

* ~~Ansicht mit aktuellen Schulden~~
* ~~SuperAdmin~~
* ~~generell Rolen einfügen~~
* Datatable als Counter, jede Row Preis + Created at!

* CI/CD einreichten

Add role to user

```elixir
user |> Ecto.Changeset.cast(%{}, []) |> Ecto.Changeset.put_assoc(:roles, [role | user.roles]) |> BeerDispenser.Repo.update
```
