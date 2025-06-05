//
//  ForecastResponse.swift
//  Space S
//
//  Created by 김재현 on 6/5/25.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable, Identifiable {
    var id: UUID { UUID() } // For SwiftUI ForEach
    let dt: TimeInterval
    let main: ForcastMainWeather
    let weather: [WeatherDetail]
}

struct ForcastMainWeather: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}

struct WeatherDetail: Codable {
    let main: String
    let description: String
    let icon: String
}

struct City: Codable {
    let name: String
    let country: String
}
