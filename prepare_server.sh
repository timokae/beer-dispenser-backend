#!/bin/bash

# env $(cat ../.env | xargs) npm i

# Compile app assets
env $(cat .env | xargs) npm run deploy --prefix ./assets
env $(cat .env | xargs) mix phx.digest

env $(cat .env | xargs) mix deps.get --only prod
env $(cat .env | xargs) mix compile

