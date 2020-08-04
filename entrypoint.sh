#!/bin/bash
# Docker entrypoint script.

# Wait until Postgres is ready

while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."

  echo "Creating database $PGDATABASE"
  createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
  # mix ecto.create

  export MIX_ENV=prod
  echo "Running migrations on $PGDATABASE"
  mix ecto.migrate

  echo "Seeding database $PGDATABASE"
  mix run priv/repo/seeds.exs

  echo "Database $PGDATABASE created."
fi

exec mix phx.server
