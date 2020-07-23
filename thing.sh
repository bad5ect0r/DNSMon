#!/bin/bash

APP_TOKEN=""
USER_TOKEN=""

TARGETS=""
DOW=$(date +%u)
if [ $DOW -eq 1 ]; then
    TARGETS="Monday"
elif [ $DOW -eq 2 ]; then
    TARGETS="Tuesday"
elif [ $DOW -eq 3 ]; then
    TARGETS="Wednesday"
elif [ $DOW -eq 4 ]; then
    TARGETS="Thursday"
elif [ $DOW -eq 5 ]; then
    TARGETS="Friday"
elif [ $DOW -eq 6 ]; then
    TARGETS="Saturday"
else
    TARGETS="Sunday"
fi
TARGETS="$TARGETS/targets.txt"
echo "Choosing TARGETS file $TARGETS"

if [ ! -f $TARGETS ]; then
    echo "$TARGETS does not exist!"
    exit 1
fi

for target in $(cat $TARGETS); do
    TITLE="Amass Notification ($(echo $target | awk -F '/' '{print $NF}'))"

    echo "Running amass for $target..."
    amass enum -src -active -df $target/DNS/root_domains.txt -config $target/DNS/amass.ini -o $target/DNS/amass_results.txt -dir $target/DNS/amass_dir -brute -w $1
    RESULT=$(amass track -df $target/DNS/root_domains.txt  -config $target/DNS/amass.ini -last 2 -dir $target/DNS/amass_dir | grep Found | awk '{print $2}')

    FINAL_RESULT=$(while read -r d; do if grep --quiet "$d" $target/DNS/all_domains.txt; then continue; else echo "$d"; fi; done <<< $RESULT)

    if [ -z "$FINAL_RESULT" ]; then
        sleep 3600
        continue
    else
        echo "$FINAL_RESULT" >> $target/DNS/all_domains.txt
    fi

    wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$FINAL_RESULT&title=$TITLE" -qO- > /dev/null 2>&1 &
done

