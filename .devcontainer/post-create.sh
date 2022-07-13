#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "$(date)    post-create start" >> ~/status

# Install Azure Developer Cli
curl -L https://aka.ms/InstallAzureCli | bash

# update the base docker images
docker pull mcr.microsoft.com/dotnet/sdk:6.0-alpine
docker pull mcr.microsoft.com/dotnet/aspnet:6.0-alpine
docker pull bjd145/utils:3.9

echo "$(date)    post-create complete" >> ~/status
