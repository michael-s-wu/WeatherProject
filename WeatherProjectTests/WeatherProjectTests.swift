//
//  WeatherProjectTests.swift
//  WeatherProjectTests
//
//  Created by Michael Wu on 5/6/23.
//

import XCTest
@testable import WeatherProject

final class WeatherProjectTests: XCTestCase {
    
    /// Tests the geocoder API for the happy path and error handling for bad input.
    func testGeocoderAPI() async throws {
        
        // Test "happy path" to ensure geocoder API functions
        var happyGeodata: GeoData? = nil
        let happyExp = expectation(description: "Check happy path for geodata API")
        
        Geocoder.fetchCoordinates(for: "London") { geoData in
            happyGeodata = geoData
            happyExp.fulfill()  // API call has returned, can move on to verifying data
        }
        
        // Test bad data to check error handling
        var badGeodata: GeoData? = nil
        let badExp = expectation(description: "Check geodata API for bad data")
        
        Geocoder.fetchCoordinates(for: "Aaaaaaaaaaaaaaaa") { geoData in
            badGeodata = geoData
            badExp.fulfill()  // API call has returned, can move on to verifying data
        }
        
        // Once all API calls have completed, verify data
        await waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            XCTAssertNotNil(happyGeodata)
            XCTAssertNil(badGeodata)
        }
    }

    /// Tests the weather API for the happy path and error handling for bad input.
    func testWeatherAPI() async throws {
        
        // Test "happy path" (London coordinates) to ensure weather API functions
        var happyWeatherData: WeatherData? = nil
        let happyExp = expectation(description: "Check happy path for weather API")
        
        WeatherFetcher.fetchWeather(latitude: 51.5, longitude: -0.12, callback: { weatherData in
            happyWeatherData = weatherData
            happyExp.fulfill()  // API call has returned, can move on to verifying data
        })
        
        // Test bad data to check error handling
        var badWeatherData: WeatherData? = nil
        let badExp = expectation(description: "Check weather API with bad data")
        
        WeatherFetcher.fetchWeather(latitude: 100000000, longitude: 100000000, callback: { weatherData in
            badWeatherData = weatherData
            badExp.fulfill()  // API call has returned, can move on to verifying data
        })
        
        // Once all API calls have completed, verify data
        await waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            XCTAssertNotNil(happyWeatherData)
            XCTAssertNil(badWeatherData)
        }
    }

    /// Tests the icon fetcher for the happy path and error handling for bad input.
    func testIconFetcher() async throws {
        
        // Test "happy path" (cloudy icon) to ensure icon fetcher functions
        var happyIcon: UIImage? = nil
        let happyExp = expectation(description: "Check happy path for icon fetcher")
        
        IconFetcher.downloadImage(from: "04n") { icon in
            happyIcon = icon
            happyExp.fulfill()
        }
        
        // Test bad data to check error handling
        var badIcon: UIImage? = nil
        let badExp = expectation(description: "Check icon fetcher with bad input")
        
        IconFetcher.downloadImage(from: "aaaaaaaaaaaa") { icon in
            badIcon = icon
            badExp.fulfill()
        }
        
        // Once all icons have been fetched, verify data
        await waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            XCTAssertNotNil(happyIcon)
            XCTAssertNil(badIcon)
        }
    }

}
