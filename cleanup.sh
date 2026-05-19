#!/bin/bash
docker compose down
rm -rf data/config/agent/sessions
rm -rf workdir/.git 2> /dev/null