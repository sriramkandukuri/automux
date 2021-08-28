#!/bin/bash

cat ./automux.sh | grep "^#H" ./automux.sh | sed -e 's/^#H/\n/g' | cut -d" " -f2- > ./README.md
