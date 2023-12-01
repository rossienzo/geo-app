#!/bin/bash
topic="topic/disconnection"
host="localhost"

echo "mosquitto $topic on $host"
mosquitto_sub -h $host -t $topic