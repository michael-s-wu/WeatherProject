//
//  WeatherViewModel.swift
//  WeatherProject
//
//  Created by Michael Wu on 5/6/23.
//

import UIKit

protocol WeatherManagerDelegate {
    /// Called when the weather data is updated.
    func didUpdateWeather()
    
    /// Called when then view model's icon is updated.
    func didUpdateIcon()
    
    /// Called when the coordinates for the given city cannot be fetched.
    func errorFetchingCoordinates()
    
    /// Called when the weather for the given coordinates cannot be fetched.
    func errorFetchingWeather()
    
    /// Called when the weather icon cannot be fetched.
    func errorFetchingIcon()
}

class WeatherViewModel {
    
    //MARK: - Properties
    var cityName: String?
    private var temperature: Double?
    var temperatureString: String {
        return String(format: "%.1f", temperature ?? 0)  // Format temperature string to only have 1 decimal place
    }
    var weatherIcon: UIImage?
    var delegate: WeatherManagerDelegate?
        
    
    //MARK: - Public
    func fetchWeather(cityName: String) {
        
        // First fetch the longitude / latitude
        Geocoder.fetchCoordinates(for: cityName) { [self] geodata in
            
            // Fetch the weather information if the latitude / longitude is valid
            if let geodata = geodata {
                print("Got coordinates: \(geodata)")
                fetchWeather(latitude: geodata.lat, longitude: geodata.lon)
            } else {
                delegate?.errorFetchingCoordinates()  // Inform view of error
            }
        }
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        WeatherFetcher.fetchWeather(latitude: latitude, longitude: longitude) { [self] weather in
            
            if let weather = weather {
                print("Got weather: \(weather)")
                cityName = weather.name
                temperature = weather.main.temp
                delegate?.didUpdateWeather()  // Inform view that the view model data has been updated
                
                // Weather has been fetched, fetch icon
                fetchWeatherIcon(for: weather.weather[0].icon)
            } else {
                delegate?.errorFetchingWeather()  // Inform view of error
            }
        }
    }
    
    
    //MARK: - Private
    
    private func fetchWeatherIcon(for weatherId: String) {
        IconFetcher.downloadImage(from: weatherId) { [self] weatherIcon in
            if let weatherIcon = weatherIcon {
                print("Got weather icon.")
                self.weatherIcon = weatherIcon
                delegate?.didUpdateIcon()  // Inform view that the icon has been updated
            } else {
                delegate?.errorFetchingIcon()  // Inform view of error
            }
        }
    }
    
}
