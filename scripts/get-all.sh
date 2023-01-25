#!/bin/bash

export $(azd env get-values | grep -i APP_API_BASE_URL | tr -d '\"')

echo Get All
curl -s ${APP_API_BASE_URL}/todos | jq
