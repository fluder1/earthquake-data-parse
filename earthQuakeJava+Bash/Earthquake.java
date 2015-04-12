package commands;

/**
 * Earthquake objects from JSON file
 * 
 * @author Alan Fluder
 */
public class Earthquake {
	private String magnitude;
	private String dateStamp;
	private String latitude;
	private String longitude;

	public Earthquake(String rawData) {
		String[] rawDataElements = rawData.split(",");
		magnitude = rawDataElements[0];
		dateStamp = rawDataElements[1];
		latitude = rawDataElements[2];
		longitude = rawDataElements[3];
	}

	/**
	 * Compares UNIX timestamps (seconds since 1/1/1970)
	 */
	public boolean lessThanWeekOld() {
		final int singleWeekInSeconds = 604800;
		long unixTimeStamp = System.currentTimeMillis() / 1000L;
		long oneWeekAgo = unixTimeStamp - singleWeekInSeconds;
		return oneWeekAgo < Long.parseLong(dateStamp);
	}

	public Double getMagnitude() {
		return Double.parseDouble(magnitude);
	}

	/**
	 * Representation of Haversine formula for finding distance between two
	 * lat/longs
	 * 
	 * @return Distance between two points in miles
	 */
	public Double getDistance() {
		final double earthRadius = 3958.76;
		final double interanaLatitude = 37.452234;
		final double interanaLongitude = -122.166213;

		double earthquakeLatitude = Double.parseDouble(latitude);
		double earthquakeLongitude = Double.parseDouble(longitude);
		double deltaLatitude = interanaLatitude - earthquakeLatitude;
		double deltaLongitude = interanaLongitude - earthquakeLongitude;

		double distanceBetweenPoints = Math
				.sin(Math.toRadians(deltaLatitude) / 2)
				* Math.sin(Math.toRadians(deltaLatitude) / 2)
				+ Math.sin(Math.toRadians(deltaLongitude) / 2)
				* Math.sin(Math.toRadians(deltaLongitude) / 2)
				* Math.cos(Math.toRadians(interanaLatitude))
				* Math.cos(Math.toRadians(earthquakeLatitude));
		distanceBetweenPoints = 2 * Math.asin(Math.sqrt(distanceBetweenPoints));
		distanceBetweenPoints = earthRadius * distanceBetweenPoints;
		return distanceBetweenPoints;
	}

	/**
	 * Custom printout for user
	 */
	public String toString() {
		return "Magnitude: " + magnitude + " UNIX Time: " + dateStamp
				+ " Latitude/Longitude: " + latitude + ", " + longitude;
	}
}