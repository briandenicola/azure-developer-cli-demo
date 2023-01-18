#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
SRC_PATH=$(realpath "${SCRIPT_DIR}/../src/ui/wwwroot")

export $(azd env get-values | grep -i API_URI | tr -d '\"')
export $(azd env get-values | grep -i UI_URI | tr -d '\"')

cat << EOF > ${SRC_PATH}/appsettings.json
{
    "API_URI": "${API_URI}"
}
EOF

azd deploy --cwd ${SCRIPT_DIR}/.. --service ui