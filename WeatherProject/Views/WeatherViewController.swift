//
//  WeatherViewController.swift
//  WeatherProject
//
//  Created by Michael Wu on 5/6/23.
//

import UIKit
import CoreLocation
import SwiftUI

class WeatherViewController: UIViewController {
    
    //MARK: - Properties
    private var weatherViewModel = WeatherViewModel()
    private let locationManager = CLLocationManager()
    
    private let locationButton = UIButton()
    private let searchBar = UITextField()
    private let searchButton = UIButton()
    private var temperatureView = TemperatureView(weatherIcon: nil, temperature: "", city: "")
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherViewModel.delegate = self  // Set the view model's delegate to receive updates

        createUI()
        
        // Add tap target for buttons
        locationButton.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()  // Request location services from the user
        
        // If location services are already authorized, fetch location
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()  // If location services are enabled, fetch the user's location
        default:
            // Check for last used city
            if let lastUsedCity = UserDefaults.standard.string(forKey: Consts.lastUsedCity) {
                fetchWeather(city: lastUsedCity)
            }
        }
        
    }
    
    
    //MARK: - Private
    
    /// Builds the UI from the view model data.
    private func createUI() {
        
        // Set location button
        locationButton.setImage(UIImage(systemName: "location.circle"), for: .normal)
        locationButton.setTitle("", for: .normal)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set search bar
        searchBar.placeholder = "Search"
        searchBar.returnKeyType = .go
        searchBar.delegate = self
        searchBar.textAlignment = .left
        searchBar.borderStyle = .roundedRect
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Set search button
        searchButton.setImage(UIImage(systemName: "magnifyingglass.circle"), for: .normal)
        searchButton.setTitle("", for: .normal)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create search stack view
        let searchStack = UIStackView()
        searchStack.axis = .horizontal
        searchStack.distribution = .fillProportionally
        searchStack.spacing = 16
        searchStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Add elements to search stack view
        searchStack.addArrangedSubview(locationButton)
        searchStack.addArrangedSubview(searchBar)
        searchStack.addArrangedSubview(searchButton)
        
        // Create hosting controller to hold SwiftUI temperature view
        let hostingController = UIHostingController(rootView: temperatureView)
        let swiftUIView = hostingController.view!
        swiftUIView.translatesAutoresizingMaskIntoConstraints = false

        // Add views to primary view
        addChild(hostingController)
        view.addSubview(searchStack)
        view.addSubview(swiftUIView)
        
        // Create layout padding values from safe area insets plus additional margin
        let leftPadding = view.safeAreaInsets.left + 16
        let rightPadding = (view.safeAreaInsets.right + 16) * -1  // Right padding is negative so the constraint is applied in the correct direction
        
        // Set constraints for UI elements
        NSLayoutConstraint.activate([
            locationButton.heightAnchor.constraint(equalToConstant: 32),
            locationButton.widthAnchor.constraint(equalToConstant: 32),
            searchBar.heightAnchor.constraint(equalToConstant: 32),
            searchButton.heightAnchor.constraint(equalToConstant: 32),
            searchButton.widthAnchor.constraint(equalToConstant: 32),

            searchStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            searchStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftPadding),
            searchStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: rightPadding),
            
            swiftUIView.topAnchor.constraint(equalTo: searchStack.bottomAnchor, constant: 50),
            swiftUIView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftPadding),
            swiftUIView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: rightPadding)
        ])
        
        // Notify child view controller that it has been moved
        hostingController.didMove(toParent: self)
    }
    
    /// Asks the view model to fetch the weather for the given city string.
    private func fetchWeather(city: String) {
        if city == "" {
            return  // Ignore if city is empty
        }
        
        UserDefaults.standard.set(city, forKey: Consts.lastUsedCity)  // Store last searched city
        weatherViewModel.fetchWeather(cityName: city)  // Ask view model to fetch weather for city
    }
    
    
    //MARK: - Button actions
    @objc func searchButtonPressed() {
        fetchWeather(city: searchBar.text ?? "")  // Fetch weather for city in the search bar
        searchBar.resignFirstResponder()  // Hide keyboard
    }
    
    @objc func locationButtonPressed() {
        
        // Check location services status
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()  // If location services are enabled, fetch the user's location
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()  // Request location services from the user
            
        default:
            // Show pop-up error
            let alert = UIAlertController(title: "Permissions Error", message: "Location services are disabled. Please enable them in your Settings app to use your location.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) {_ in }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
}



//MARK: - UI text field delegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Hide keyboard
        fetchWeather(city: textField.text ?? "") // Fetch weather when user presses "Go" button on keyboard
        return true
    }
}


//MARK: - Weather manager delegate
extension WeatherViewController: WeatherManagerDelegate {

    func didUpdateWeather() {
        // View model's temperature info has been updated, refresh UI on main thread
        DispatchQueue.main.async { [self] in
            temperatureView = TemperatureView(weatherIcon: nil, temperature: weatherViewModel.temperatureString, city: weatherViewModel.cityName ?? "")
            createUI()
        }
    }
    
    func didUpdateIcon() {
        // View model's weather icon has been updated, refresh UI on main thread
        DispatchQueue.main.async { [self] in
            temperatureView = TemperatureView(weatherIcon: weatherViewModel.weatherIcon, temperature: weatherViewModel.temperatureString, city: weatherViewModel.cityName ?? "")
            createUI()
        }
    }
    
    func errorFetchingCoordinates() {
        // Show pop-up error
        let alert = UIAlertController(title: "Error Fetching Weather", message: "Please double check your entered city and try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) {_ in }
        alert.addAction(okAction)
        
        DispatchQueue.main.async { [self] in
            present(alert, animated: true, completion: nil)
        }
    }
    
    func errorFetchingWeather() {
        // Show pop-up error
        let alert = UIAlertController(title: "Error Fetching Weather", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) {_ in }
        alert.addAction(okAction)
        
        DispatchQueue.main.async { [self] in
            present(alert, animated: true, completion: nil)
        }    }
    
    func errorFetchingIcon() {
        // Show pop-up error
        let alert = UIAlertController(title: "Error Fetching Icon", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) {_ in }
        alert.addAction(okAction)
        
        DispatchQueue.main.async { [self] in
            present(alert, animated: true, completion: nil)
        }    }
}


//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {  // Grabs the coordinates from the most recent location data
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            // Ask view model to fetch weather for coordinates
            weatherViewModel.fetchWeather(latitude: lat, longitude: lon)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        
        // Update UI on main thread
        DispatchQueue.main.async { [self] in
            temperatureView = TemperatureView(weatherIcon: nil, temperature: "Error fetching location.", city: "")
            createUI()
        }

    }
    
}
