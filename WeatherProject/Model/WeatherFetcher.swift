//
//  WeatherManager.swift
//  WeatherProject
//
//  Created by Michael Wu on 5/6/23.
//

import Foundation

struct WeatherFetcher {
    
    static func fetchWeather(latitude: Double, longitude: Double, callback: @escaping (WeatherData?) -> () ) {
        
        // Create URL
        let urlString = "https://api.openweathermap.org/data/2.5/weather?appid=\(Consts.apiKey)&units=imperial&lat=\(latitude)&lon=\(longitude)"

        if let url = URL(string: urlString) {
            
            // Create a URLSession
            let session = URLSession(configuration: .default)
            
            // Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    print("Error fetching weather: \(String(describing: error))")
                    callback(nil)  // Let view model know fetching failed
                    return
                }
                
                // Unwrap data
                if let safeData = data {
                    
                    do {
                        let results = try JSONDecoder().decode(WeatherData.self, from: safeData)
                        callback(results)  // Send data back to view model
                        
                    } catch {
                        print("Error: \(error)")
                        callback(nil)  // Let view model know fetching failed
                    }
                }
            }
            
            // Start the task
            task.resume()
            
        }
        
    }
    
}

struct WeatherData: Codable {
    let name: String?
    let main: Main
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double  // Capture the temperature in the nested "main" dictionary
    }

    struct Weather: Codable {
        let icon: String  // Capture the icon code from the "weather" dictionary
    }
}
