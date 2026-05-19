#!/bin/bash
docker compose up --build
echo "attaching to internal tui..."
./attach.sh