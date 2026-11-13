#!/bin/bash
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "This cannot be executed directly - credentials need to be in your env"
    echo "run source $0"
    exit 1
fi
#Run aws login
eval "$(aws configure export-credentials --profile default --format env)"
aws sts get-caller-identity >/dev/null
