#!/bin/bash

/opt/portainer/portainer &

sleep 5

PORTAINER_PASS=$(cat /run/secrets/portainer_pass)

curl -s -X POST http://localhost:9000/api/users/admin/init \
    -H "Content-Type: application/json" \
    -d "{\"Username\":\"$PORTAINER_USER\",\"Password\":\"$PORTAINER_PASS\"}"

wait