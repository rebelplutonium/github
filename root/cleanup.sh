#!/bin/sh

cd /opt/docker/workspace &&
    git checkout -b cleanup_$(uuidgen) &&
    git commit -am "shutdown cleanup commit"