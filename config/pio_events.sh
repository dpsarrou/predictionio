#!/usr/bin/env bash

echo "Establishing elasticsearch connection"
until $(curl --output /dev/null --silent --head --fail http://elasticsearch:9200); do
    printf '.'
    sleep 5
done

pio eventserver