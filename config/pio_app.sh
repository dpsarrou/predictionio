#!/usr/bin/env bash

if [ ! -d "/app/$PIO_APP_NAME" ]; then
  echo -e "No application installed. Exiting.."
  sleep 20;
  exit 0;
fi;

echo "Establishing connection with PredictionIO events store"
until $(curl --output /dev/null --silent --head --fail http://pio_events:7070); do
    printf '.'
    sleep 5
done

pio app list 2>&1 | grep -qi "$PIO_APP_NAME"

if [ $? -ne 0 ] ; then
  pio app new $PIO_APP_NAME --access-key $PIO_APP_KEY
fi;

cd /app/$PIO_APP_NAME

pio train
pio deploy