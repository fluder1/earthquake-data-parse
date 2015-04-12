#!/bin/bash

i=1
while read line
do
    test $i -eq 1 && ((i=i+1)) && continue
    rawData=$(echo "$line" | cut -d":" -f 4,6,34)
    magnitude=$(echo $rawData | cut -d"," -f1)    
    dateStamp=$(echo $rawData | cut -d":" -f2 | cut -b 1-10)
    latitude=$(echo $rawData |  cut -d"," -f4)
    longitude=$(echo $rawData | cut -d"," -f3 | cut -d"[" -f2)

echo $magnitude,$dateStamp,$latitude,$longitude >> /tmp/trimmedEarthquakeData
done < $1
echo Trimmed data ready
