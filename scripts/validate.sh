#!/bin/bash

export $(azd env get-values | grep -i API_URI | tr -d '\"')

echo Health Check
curl -w '\n' ${API_URI}/

echo Post Sample Items
curl -sX POST ${API_URI}/todos/ -d '{"Id": "123456", "Name": "Take out trash"}' -H "Content-Type: application/json" 
curl -sX POST ${API_URI}/todos/ -d '{"Id": "7891011", "Name": "Clean your bathroom"}' -H "Content-Type: application/json" 
echo

echo Get Todo ID# 123456
curl -s ${API_URI}/todos/123456 | jq

echo Update Todo# 7891011
curl -sX PUT ${API_URI}/todos/7891011 -d '{"Id": "7891011", "Name": "Clean your bathroom", "IsComplete": true }' -H "Content-Type: application/json" 
curl -s ${API_URI}/todos/7891011 | jq

echo Get All
curl -s ${API_URI}/todos | jq