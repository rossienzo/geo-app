#!/bin/bash
topic="topic/accident"
host="localhost"

echo "mosquitto $topic on $host"
mosquitto_sub -h $host -t $topic