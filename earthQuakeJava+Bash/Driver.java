package commands;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

/**
 * Prints strongest earthquake, within 100 miles of Interana's office that
 * occurred in the last 7 days. Pre-req is a trimmed json earthquake data file
 * which can be generated using the getData.sh script.
 * 
 * @author Alan Fluder
 */
public class Driver {

	private static Double maxMagnitude = 0.0;
	private static Earthquake highestMagnitudeEarthquake;

	public static void main(String[] args) {
		new Driver().parseFile();
	}

	/**
	 * Cycles through earthquakes
	 */
	public void parseFile() {
		Scanner scanner = makeScannerFor("trimmedEarthquakeData");
		while (scanner.hasNext()) {
			Earthquake newEarthquake = new Earthquake(scanner.nextLine());
			checkIfValidEarthquake(newEarthquake);
		}
		scanner.close();
		System.out.println(highestMagnitudeEarthquake.toString());
	}

	/**
	 * Allows parsing of specified file
	 * 
	 * @param path
	 *            to data file
	 */
	public Scanner makeScannerFor(String dataFileName) {
		File jsonFile = new File(dataFileName);
		Scanner scanner = null;
		try {
			scanner = new Scanner(jsonFile);
		} catch (FileNotFoundException e) {
			System.out.println("Data file not found");
		}
		return scanner;
	}

	/**
	 * Checks magnitude, age and distance of earthquake
	 * 
	 * @param Custom
	 *            object for earthquakes
	 */
	public void checkIfValidEarthquake(Earthquake newEarthquake) {
		if (newEarthquake.getMagnitude() > maxMagnitude) {
			if (newEarthquake.lessThanWeekOld()) {
				if (newEarthquake.getDistance() < 100) {
					maxMagnitude = newEarthquake.getMagnitude();
					highestMagnitudeEarthquake = newEarthquake;
				}
			}
		}
	}
}
