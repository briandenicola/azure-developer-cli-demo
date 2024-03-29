#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "$(date)    post-create start" >> ~/status

# Install Azure Developer Cli
curl -fsSL https://aka.ms/install-azd.sh | bash

# update the base docker images
docker pull mcr.microsoft.com/dotnet/sdk:6.0-alpine
docker pull mcr.microsoft.com/dotnet/aspnet:6.0-alpine

# install psql
sudo apt-get update -qq -y
sudo apt-get -y install postgresql-client postgresql-contrib

echo "$(date)    post-create complete" >> ~/status
