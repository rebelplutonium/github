#!/bin/sh

while ! git push --follow-tags origin $(git rev-parse --abbrev-ref HEAD)
do
    sleep 10s
done &&
    git standing