#!/bin/bash

export $(azd env get-values | grep -i API_URI | tr -d '\"')
export $(azd env get-values | grep -i UI_URI | tr -d '\"')

cat << EOF > ../src/ui/wwwroot/appsettings.json
{
    "API_URI": "${API_URI}"
}
EOF

azd deploy --cwd .. --service ui