#!/usr/bin/env bash

echo "Establishing connection with PredictionIO events store"
until $(curl --output /dev/null --silent --head --fail http://pio_events:7070); do
    printf '.'
    sleep 5
done

cd /apps/$PIO_APP_NAME/

pio app list 2>&1 | grep -qi "$PIO_APP_NAME"

if [ $? -ne 0 ] ; then
  pio app new $PIO_APP_NAME --access-key $PIO_APP_KEY
fi;

pio train
pio deploy
