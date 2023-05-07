//
//  IconFetcher.swift
//  WeatherProject
//
//  Created by Michael Wu on 5/6/23.
//

import UIKit

struct IconFetcher {
        
    static func downloadImage(from icon: String, callback: @escaping (UIImage?) -> () ) {
        
        if let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {  // Ensure data is valid & no errors
                    print("Error fetching weather icon: \(String(describing: error))")
                    callback(nil)  // Let view model know fetching failed
                    return
                }
                
                if let image = UIImage(data: data) {  // Convert fetched data to UIImage
                    callback(image)
                } else {
                    print("Error converting weather icon.")
                    callback(nil)  // Let view model know fetching failed
                }
                
            }.resume()
        }
    }
}
