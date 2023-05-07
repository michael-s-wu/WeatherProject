//
//  TemperatureView.swift
//  WeatherProject
//
//  Created by Michael Wu on 5/6/23.
//

import SwiftUI

struct TemperatureView: View {
    let weatherIcon: UIImage?
    let temperature: String
    let city: String

    var body: some View {
        VStack() {
            Image(uiImage: weatherIcon ?? UIImage(systemName: "cloud.fill")!)
                .frame(width: 50, height: 50)
                .opacity(weatherIcon == nil ? 0 : 1)  // Hide image if no icon is provided
            Text(temperature == "" ? "Please enter a city to fetch the weather." : "\(temperature)℉")  // If temperature is not set, prompt the user to enter their city.
                .font(.system(size:32))
                .padding(.all)
            Text(city)
        }

    }
}

struct TemperatureView_Previews: PreviewProvider {
    static var previews: some View {
        TemperatureView(
            weatherIcon: UIImage(systemName: "cloud.fill")!, temperature: "45", city: "Palo Alto")
    }
}
