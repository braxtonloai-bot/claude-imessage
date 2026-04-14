#!/bin/bash

# Send an iMessage to a contact
# Usage: ./send-message.sh "Phone Number" "Message Text"
# Or: echo "Message Text" | ./send-message.sh "Phone Number"

if [ -z "$1" ]; then
    echo "Usage: $0 \"Phone Number\" [\"Message Text\"]"
    exit 1
fi

CONTACT="$1"
MESSAGE="${2:-}"

if [ -z "$MESSAGE" ] && [ ! -t 0 ]; then
    MESSAGE=$(cat)
fi

if [ -z "$MESSAGE" ]; then
    echo "Error: No message text provided"
    exit 1
fi

# Normalize phone number - add +1 prefix if needed
PHONE="$CONTACT"
if [[ ! "$PHONE" =~ ^\+ ]]; then
    if [[ ${#PHONE} == 10 ]]; then
        PHONE="+1${PHONE}"
    elif [[ ${#PHONE} == 11 && "$PHONE" =~ ^1 ]]; then
        PHONE="+${PHONE}"
    fi
fi

osascript \
    -e 'on run argv' \
    -e '  set msg to item 1 of argv' \
    -e '  set ph to item 2 of argv' \
    -e '  tell application "Messages"' \
    -e '    set targetService to 1st account whose service type = iMessage' \
    -e '    set targetBuddy to participant ph of targetService' \
    -e '    send msg to targetBuddy' \
    -e '  end tell' \
    -e 'end run' \
    -- "$MESSAGE" "$PHONE"
