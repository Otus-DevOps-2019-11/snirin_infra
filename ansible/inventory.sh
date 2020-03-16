#!/bin/bash

app_external_ip=$(cd ../terraform/stage && terraform output app_external_ip)
db_external_ip=$(cd ../terraform/stage && terraform output db_external_ip)
db_internal_ip=$(cd ../terraform/stage && terraform output db_internal_ip)

cat <<EOF
{
  "app": {
    "hosts": ["$app_external_ip"]
  },
  "db": {
    "hosts": ["$db_external_ip"],
    "internal_ip": "$db_internal_ip"
  }
}
EOF
