#!/bin/bash

# Silence an alert in Grafana Alertmanager, based on the instance label.
# Alertmanager as datasource is used, alertmanager UID is required.
# Usage: ./silence.bash <instance> <duration>
# Example: ./silence.bash jupiter:9873 +1H
# Default duration is +1H
#
# Dependencies:
# - curl
# - jq
#
# Environment variables:
# - GRAFANA_URL: Grafana URL
# - GRAFANA_TOKEN: Grafana API token
# - ALERTMANAGER_UID: Alertmanager UID

# Check if the correct number of arguments are provided
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf "Usage: %s <instance> <duration>\nExample:\n\t./silence.bash jupiter:9873 +1H\nDefault duration is +1H" "$0"
  exit 1
fi

# Check if the environment variables are set
if [ -z "$GRAFANA_URL" ] || [ -z "$GRAFANA_TOKEN" ] || [ -z "$ALERTMANAGER_UID" ]; then
  echo "Error: GRAFANA_URL, GRAFANA_TOKEN, and ALERTMANAGER_UID environment variables must be set."
  exit 1
fi

INSTANCE="$1"
DURATION="${2:-+1H}"

SILENCE_URL="${GRAFANA_URL}api/alertmanager/${ALERTMANAGER_UID}/api/v2/silences"

STARTS_AT=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
ENDS_AT=$(date -u -v "$DURATION" +'%Y-%m-%dT%H:%M:%SZ')
PAYLOAD=$(cat <<EOF
{
  "matchers": [
    {
      "name": "instance",
      "value": "$INSTANCE",
      "isRegex": false
    }
  ],
  "startsAt": "$STARTS_AT",
  "endsAt": "$ENDS_AT",
  "createdBy": "$(whoami)@$(hostname)",
  "comment": "Silencing instance=$INSTANCE for $DURATION."
}
EOF
)

# Do the thing
result=$(curl --silent -H "Authorization: Bearer $GRAFANA_TOKEN" \
     -H "Content-Type: application/json" \
     -X POST \
     -d "$PAYLOAD" \
     "$SILENCE_URL"
)
# Check the result with jq. It mustn't contain "message" key and must contain "silenceID" key.
if echo "$result" | jq -e 'has("message")' &>/dev/null; then
  echo "Error: $(echo "$result" | jq -r '.message')"
  exit 1
elif ! echo "$result" | jq -e 'has("silenceID")' &>/dev/null; then
  echo "Error: silenceID not found in the response."
  exit 1
else
  printf "Silence %s created successfully" "$(echo "$result" | jq -r '.silenceID')"
fi
