#!/bin/bash

export $(azd env get-values | grep -i APP_API_BASE_URL | tr -d '\"')

echo Health Check
curl -w '\n' ${APP_API_BASE_URL}/

echo Post Sample Items
curl -sX POST ${APP_API_BASE_URL}/todos/ -d '{"Id": "123456", "Name": "Take out trash"}' -H "Content-Type: application/json" 
curl -sX POST ${APP_API_BASE_URL}/todos/ -d '{"Id": "7891011", "Name": "Clean your bathroom"}' -H "Content-Type: application/json" 
echo

echo Get Todo ID# 123456
curl -s ${APP_API_BASE_URL}/todos/123456 | jq

echo Update Todo# 7891011
curl -sX PUT ${APP_API_BASE_URL}/todos/7891011 -d '{"Id": "7891011", "Name": "Clean your bathroom", "IsComplete": true }' -H "Content-Type: application/json" 
curl -s ${APP_API_BASE_URL}/todos/7891011 | jq

echo Get All
curl -s ${APP_API_BASE_URL}/todos | jq