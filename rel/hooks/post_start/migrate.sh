#!/bin/sh


set +e

while true; do
  nodetool ping
  EXIT_CODE=$?

  if [ $EXIT_CODE -eq 0 ]; then
    echo "Application is up!"
    break
  fi
done

set =e

echo "Running migrations"
release_ctl eval --mfa "Snitch.Tasks.ReleaseTasks.migrate/0" -- "$@"
echo "Migrations run successfully"
