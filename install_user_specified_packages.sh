#!/bin/sh
if [ -e /code/apk_packages.txt ]; then
 while IFS='' read line; do
  apk add --no-cache $line; 
 done < /code/apk_packages.txt; 
fi 
