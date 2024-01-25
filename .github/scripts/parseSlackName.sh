#!/bin/bash

#  find the slack namne
SLACK_NAME=$(jq '.users[] | select(.github == "chrisfrey-gp").slack' slack.json | sed -r 's/["]+//g')

echo "Slack name is $SLACK_NAME"
