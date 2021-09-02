#!/bin/bash

cat ./automux.sh | grep "^#H" ./automux.sh | sed -e 's/^#H//g' | cut -d" " -f2- | sed -e 's/^#/\n#/g' > ./README.md
