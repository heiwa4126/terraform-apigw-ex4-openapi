#!/bin/sh -ue
. ./tmp/env.sh
echo '== will display {"message": "Invalid request body"} or anything'

curl -XPOST "$TFO_endpoint/add" -H "Content-Type: application/json" -d '{"a":1,"c":2}'
echo
curl -XPOST "$TFO_endpoint/add" -H "Content-Type: application/json" -d '{"a":1}'
echo
curl -XPOST "$TFO_endpoint/add" -H "Content-Type: application/json" -d '{"a":1,"b":"2"}'
echo

curl "$TFO_endpoint/add?a=1&c=2"
echo
curl "$TFO_endpoint/add?a=1"
echo
curl "$TFO_endpoint/add?a=1&b=z"
echo
