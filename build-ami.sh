#!/bin/bash

set -ex

# Install packer https://www.packer.io/intro/getting-started/install.html

# Export these environment variables
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_REGION
# USERNAME
# SSH_PUBLIC_KEY
templateName=build-server-ami.json

# Validate the packer template
packer validate $templateName

# Build ami
packer build $templateName
