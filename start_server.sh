#!/bin/bash
sudo -E env "PATH=$PATH" env $(cat .env | xargs) iex -S mix phx.server
