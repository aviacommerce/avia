#!/bin/sh
release_ctl eval --mfa "Snitch.Tasks.ReleaseTasks.migrate/0" -- "$@"
