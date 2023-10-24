#!/bin/bash
QUEUE_URL="https://sqs.eu-central-1.amazonaws.com/475032304489/snail-test-queue"
for i in 1 2 3 4 5 6 7 8 9 10
do
    aws sqs send-message \
    --profile techstarte \
    --queue-url $QUEUE_URL \
    --message-body "Test $i"
done