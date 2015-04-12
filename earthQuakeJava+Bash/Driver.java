package commands;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;


public class Driver {
	
	private static Double maxMagnitude=0.0;
	private static Earthquake highestMagnitudeEarthquake;
    public static void main(String[] args) {
    	File rawJSON = new File("/tmp/trimmedEarthquakeData");
    	
		try {
			Scanner scanner = new Scanner(rawJSON);
    	while (scanner.hasNext()) {	
    		String earthquakeDataElements = scanner.nextLine();
    		Earthquake newEarthquake = new Earthquake(earthquakeDataElements);
    	
		if (newEarthquake.getMagnitude() > maxMagnitude){
			if (newEarthquake.lessThanWeekOld()) {
				if (newEarthquake.getDistance() < 100) {
    			maxMagnitude = newEarthquake.getMagnitude();
    			highestMagnitudeEarthquake = newEarthquake;
				}
    		}
    	}
    	}
    	scanner.close();
		} catch (FileNotFoundException e) {
			System.out.println("Data file not found");
		}
		System.out.println(highestMagnitudeEarthquake.toString());
    }
}

