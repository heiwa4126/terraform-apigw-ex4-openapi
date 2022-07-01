#!/bin/sh -ue
. ./tmp/env.sh
curl "$TFO_endpoint/hello"
echo
curl "$TFO_endpoint/hello/yoshida"
echo
curl "$TFO_endpoint/goodbye"
echo
curl "$TFO_endpoint/add?a=1&b=2"
echo
curl -XPOST "$TFO_endpoint/add" -H "Content-Type: application/json" -d '{"a":1,"b":2}'
echo
