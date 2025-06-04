//
//  Weathermanage4.swift
//  Space S
//
//  Created by snlcom on 6/2/25.
//

import Foundation

// 1
struct WeatherResponse2: Codable {
    struct Weather: Codable {
        let main: String
    }
    let weather: [Weather]
}

// 2
class LaunchScheduler {
    let apiKey = "1bfc4008e2f3db1a9f06cd4fe4626d57"
    let cityName = "Austin,US"
    let weatherAPIURL: URL
    var launchDate = Date()

    init() {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"
        self.weatherAPIURL = URL(string: urlString)!
    }

    func checkWeatherAndReschedule(completion: @escaping (Date) -> Void) {
        let task = URLSession.shared.dataTask(with: weatherAPIURL) { data, response, error in
            guard let data = data else {
                print("데이터 오류:", error ?? "알 수 없는 오류")
                return
            }

            do {
                let weatherResponse2 = try JSONDecoder().decode(WeatherResponse2.self, from: data)
                let badWeatherConditions = ["Rain", "Thunderstorm", "Snow"]
                let isBadWeather = weatherResponse2.weather.contains { badWeatherConditions.contains($0.main) }

                if isBadWeather {
                    print("날씨가 안 좋아서 하루 연기합니다.")
                    self.launchDate = Calendar.current.date(byAdding: .day, value: 1, to: self.launchDate)!
                } else {
                    print("날씨가 좋아서 발사 가능합니다.")
                }

                completion(self.launchDate)
            } catch {
                print("디코딩 오류:", error)
            }
        }
        task.resume()
    }

    func saveLaunchDateToJSON(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let launchInfo = ["launch_date": formatter.string(from: date)]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: launchInfo, options: .prettyPrinted)
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("launch_date.json")
            try jsonData.write(to: fileURL)
            print("발사 날짜 JSON 저장됨: \(fileURL.path)")
        } catch {
            print("JSON 저장 실패:", error)
        }
    }
}

// 3 실행
func rescheduler() {
    let scheduler = LaunchScheduler()
    scheduler.checkWeatherAndReschedule { rescheduledDate in
        scheduler.saveLaunchDateToJSON(date: rescheduledDate)
    }
}
