#!/bin/bash
arccosOf () {
        pi="3.1415926535"
        bc -l <<< "$pi / 2 - a($1 / sqrt(1 - $1 * $1))"
}

convertCoordinates () {
    earthRadius="3958.76"
    eLat="$1"    
    eLong="$2"   
    inLat="37.452234"
    inLong="-122.166213"

    toRadianMultiplier=$(echo "3.141592654/180" | bc -l)
    toDegreeMultiplier=$(echo "180/3.141592654" | bc -l)

    deltaLat=$(echo "$inLat - $eLat" | bc -l)
    deltaLong=$(echo "$inLong - $eLong" | bc -l)
    eLatRad=$(echo "$eLat * $toRadianMultiplier" | bc -l)
    eLongRad=$(echo "$eLong * $toRadianMultiplier" | bc -l)
    inLatRad=$(echo "$inLat * $toRadianMultiplier" | bc -l)
    inLongRad=$(echo "$inLong * $toRadianMultiplier" | bc -l)
    deltaLatRad=$(echo "$deltaLat * $toRadianMultiplier" | bc -l)
    deltaLongRad=$(echo "$deltaLong * $toRadianMultiplier" | bc -l)
}

getDistanceBetweenCoordinates () {
    milesBetween=$(echo "s($eLatRad) * s($inLatRad) + c($eLatRad) * c($inLatRad) * c($deltaLongRad)" | bc -l)
    milesBetween=`arccosOf $milesBetween`
    milesBetween=$(echo "$toDegreeMultiplier * $milesBetween" | bc -l)
    milesBetween=$(echo "$milesBetween * 60 * 1.15078" | bc -l)
    milesBetween=$(echo "scale=4; $milesBetween / 1" | bc -l)
}

printData () {
    echo -n "Magnitude: $maxMagnitude  "
    echo -n "Date & Time: $finalDateStamp  "
    echo "Distance: $finalDistance  miles"
}


maxMagnitude="0.0"
currentDate=$(date +%s)
secondsPerWeek="604800"
oneWeekAgo=$(($currentDate - $secondsPerWeek))
i=1
while read line
do
    test $i -eq 1 && ((i=i+1)) && continue
    rawData=$(echo "$line" | cut -d":" -f 4,6,34)

    magnitude=$(echo $rawData | cut -d"," -f1)
    magnitudeLowerThanMax=$(echo "$magnitude<$maxMagnitude" | bc)
    if [ $magnitudeLowerThanMax = '1' ]; then 
	continue
    fi
    
    dateStamp=$(echo $rawData | cut -d":" -f2 | cut -b 1-10)
    if [ "$dateStamp" -lt "$oneWeekAgo" ]; then
	break
    fi

    
    latitude=$(echo $rawData |  cut -d"," -f4)
    longitude=$(echo $rawData | cut -d"," -f3 | cut -d"[" -f2)
    convertCoordinates $latitude $longitude
    getDistanceBetweenCoordinates
    distanceTooGreat=$(echo "$milesBetween>100" | bc)
    if [ $distanceTooGreat = '1' ]; then
	continue
    fi
    maxMagnitude=$magnitude
    finalDateStamp=$(date -d @$dateStamp +"%Y-%m-%d %H:%M:%S")
    finalDistance=$milesBetween
done < $1  
printData
