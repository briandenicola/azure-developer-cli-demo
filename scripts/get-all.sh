#!/bin/bash

export $(azd env get-values | grep -i API_URI | tr -d '\"')

echo Get All
curl -s ${API_URI}/todos | jq
