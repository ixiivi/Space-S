//
//  Weathermanage.swift
//  Space S
//
//  Created by snlcom on 6/1/25.
//

import Foundation

struct WeatherResponse: Decodable {
    let weather: [Weather]
}

struct Weather: Decodable {
    let main: String
}
