//
//  Geocoder.swift
//  WeatherProject
//
//  Created by Michael Wu on 5/6/23.
//

import Foundation

struct Geocoder {
    
    static func fetchCoordinates(for cityName: String, callback: @escaping (GeoData?) -> () ) {
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=\(Consts.apiKey)"
        
        // Create URL
        if let url = URL(string: urlString) {
            
            // Create a URLSession
            let session = URLSession(configuration: .default)
            
            // Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    print("Error fetching coordinates: \(String(describing: error))")
                    return
                }
                
                // Unwrap data
                if let safeData = data {
                    
                    do {
                        let results = try JSONDecoder().decode([GeoData].self, from: safeData)
                        
                        if results.count > 0 {
                            callback(results[0])  // Send data back to view model
                        } else {
                            callback(nil)  // Let view model know fetching failed
                        }
                        
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            
            // Start the task
            task.resume()
            
        }
        
        
    }
    
}

struct GeoData: Codable {
    let lat: Double
    let lon: Double
}
