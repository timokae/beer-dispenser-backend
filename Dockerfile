FROM elixir:alpine

# install build dependencies
RUN apk add --update git build-base nodejs npm yarn python postgresql-client

# prepare build dir
RUN mkdir /app
WORKDIR /app

ARG MIX_ENV
ARG PGUSER
ARG PGPASSWORD
ARG PGDATABASE
ARG PGPORT
ARG SECRET_KEY_BASE
ARG PGHOST
ARG SMTP_ACCOUNT
ARG SMTP_PASSWORD

ENV MIX_ENV "$MIX_ENV"
ENV PGUSER "$PGUSER"
ENV PGPASSWORD "$PGPASSWORD"
ENV PGDATABASE "$PGDATABASE"
ENV PGPORT "$PGPORT"
ENV SECRET_KEY_BASE "$SECRET_KEY_BASE"
ENV PGHOST "$PGHOST"
ENV SMTP_ACCOUNT "$SMTP_ACCOUNT"
ENV SMTP_PASSWORD "$SMTP_PASSWORD"

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
COPY assets assets
COPY priv priv
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# build project
COPY lib lib
RUN mix compile

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["sh", "/app/entrypoint.sh"]
