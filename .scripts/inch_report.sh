#!/bin/bash

set -ev

if [ $TRAVIS_PULL_REQUEST = false ]; then
    env MIX_ENV=docs mix deps.get
    env MIX_ENV=docs mix inch.report
else
    echo "Skipping Inch report because this is a PR build"
fi
