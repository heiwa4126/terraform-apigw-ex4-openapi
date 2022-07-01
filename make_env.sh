#!/bin/bash -ue
ENVFILE=./tmp/env.sh

# stack_info=$(cat ./tmp/output.json)
stack_info=$(terraform output -json)

# original at https://gist.github.com/JCotton1123/e0203791aae37f22b27dfce2c7002dbf
# and see: https://www.baeldung.com/linux/reading-output-into-array
rm -f "$ENVFILE"

IFS=$'\n' read -r -d '' -a output_keys < <(echo "$stack_info" | jq ".|keys[]" && printf '\0')
IFS=$'\n' read -r -d '' -a output_vals < <(echo "$stack_info" | jq ".[].value" && printf '\0')
for ((i = 0; i < ${#output_keys[@]}; ++i)); do
  key=$(echo "${output_keys[i]}" | sed -e 's/^"//' -e 's/"$//')
  val=$(echo "${output_vals[i]}" | sed -e 's/^"//' -e 's/"$//')
  echo "TFO_$key=\"$val\"" >>$ENVFILE
done
