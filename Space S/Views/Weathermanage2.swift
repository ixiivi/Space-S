//
//  Weathermanage2.swift
//  Space S
//
//  Created by snlcom on 6/2/25.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    private init() {}

    private let apiKey = "1bfc4008e2f3db1a9f06cd4fe4626d57"

    func fetchTexasWeather(completion: @escaping (String?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=Austin,TX,US&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard
                let data = data,
                error == nil,
                let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data)
            else {
                completion(nil)
                return
            }

            completion(weatherResponse.weather.first?.main)
        }.resume()
    }
}
