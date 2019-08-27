#!/bin/sh

# initialize terraform from plan file with plugins
terraform init ./plan

eval "$@"
