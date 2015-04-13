#!/bin/bash

#========================================#
#                                        #
#        parseEarthquakeData.sh          #
#          @author Alan Fluder           #
#              April 2015                #
#                                        #
#      Interana Earthquake Project       #
#========================================#


earthRadius="3958.76"
interanaLat="37.452234"
interanaLong="-122.166213"
toRadianMultiplier=$(echo "3.141592654/180" | bc -l)
toDegreeMultiplier=$(echo "180/3.141592654" | bc -l)
interanaLatRad=$(echo "$interanaLat * $toRadianMultiplier" | bc -l)
interanaLongRad=$(echo "$interanaLong * $toRadianMultiplier" | bc -l)
maxMagnitude="0.0"
currentDate=$(date +%s)
secondsPerWeek="604800"
oneWeekAgo=$(($currentDate - $secondsPerWeek))
pi="3.1415926535"
skipHeader=1

# Returns the inverse cosine function
get_arccos () 
{
    bc -l <<< "$pi / 2 - a($1 / sqrt(1 - $1 * $1))"
}

# Finds change in longitude and latitude for Haversine formula
convert_coordinates () 
{
    eQuakeLat=$(echo "$1" |  cut -d"," -f4)
    eQuakeLong=$(echo "$1" | cut -d"," -f3 | cut -d"[" -f2)   
    deltaLat=$(echo "$interanaLat - $eQuakeLat" | bc -l)
    deltaLong=$(echo "$interanaLong - $eQuakeLong" | bc -l)
    eQuakeLatRad=$(echo "$eQuakeLat * $toRadianMultiplier" | bc -l)
    eQuakeLongRad=$(echo "$eQuakeLong * $toRadianMultiplier" | bc -l)
    deltaLatRad=$(echo "$deltaLat * $toRadianMultiplier" | bc -l)
    deltaLongRad=$(echo "$deltaLong * $toRadianMultiplier" | bc -l)
}

# Havrsine formula via BASH
get_distance_between_coordinates () {
    milesBetween=$(echo "s($eQuakeLatRad) * s($interanaLatRad) + c($eQuakeLatRad) * c($interanaLatRad) * c($deltaLongRad)" | bc -l)
    milesBetween=$(get_arccos "$milesBetween")
    milesBetween=$(echo "$toDegreeMultiplier * $milesBetween" | bc -l)
    milesBetween=$(echo "$milesBetween * 60 * 1.15078" | bc -l)
    milesBetween=$(echo "scale=4; $milesBetween / 1" | bc -l)
}

# Print earthquake data, only used for best fit  
print_data () 
{
    echo -n "Magnitude: $maxMagnitude  "
    echo -n "Date & Time: $finalDateStamp  "
    echo "Distance: $finalDistance  miles"
}

#Saves earthquake data after passing 3 tests
#Test 1: Is magnitude greater than previous max
#Test 2: Is earthquake less than one week old
#Test 3: Is distance less than 100 miles
while read line
do
    test "$skipHeader" -eq 1 && ((skipHeader=skipHeader+1)) && continue
    rawData=$(echo "$line" | cut -d":" -f 4,6,34)
    magnitude=$(echo "$rawData" | cut -d"," -f1)
    magnitudeLowerThanMax=$(echo "$magnitude<$maxMagnitude" | bc)
    if [ "$magnitudeLowerThanMax" = '1' ]; then 
	continue
    fi
    
    dateStamp=$(echo "$rawData" | cut -d":" -f2 | cut -b 1-10)
    if [ "$dateStamp" -lt "$oneWeekAgo" ]; then
	break
    fi

    convert_coordinates "$rawData"
    get_distance_between_coordinates
    distanceTooGreat=$(echo "$milesBetween>100" | bc)
    if [ "$distanceTooGreat" = '1' ]; then
	continue
    fi
    
    maxMagnitude="$magnitude"
    finalDateStamp=$(date -d @"$dateStamp" +"%Y-%m-%d %H:%M:%S")
    finalDistance="$milesBetween"
done < "$1"  
print_data
