#!/bin/bash

set -ev

allowed_branches="^(master)|(develop)$"

if [ $TRAVIS_PULL_REQUEST = false ]; then
    if [[ $TRAVIS_BRANCH =~ $allowed_branches ]]; then
        env MIX_ENV=docs mix deps.get
        env MIX_ENV=docs mix inch.report
    else
        echo "Skipping Inch CI report because this branch does not match on /$allowed_branches/"
    fi
else
    echo "Skipping Inch CI report because this is a PR build"
fi
