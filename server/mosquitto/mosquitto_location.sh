#!/bin/bash
topic="topic/location"
host="localhost"

echo "mosquitto $topic on $host"
mosquitto_sub -h $host -t $topic