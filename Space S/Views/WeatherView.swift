//
//  WeatherView.swift
//  NewWeather
//
//  Created by 김형관 on 2023/04/25.
//  Updated to use WeatherDataModel.swift by AI
//
import SwiftUI

struct WeatherView: View {
    let forecast: ForecastResponse
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(forecast.city.name), \(forecast.city.country)")
                .font(.title2)
                .bold()
                .padding(.bottom, 4)

            if let current = forecast.list.first {
                Text("Current: \(Int(current.main.temp))°C")
                    .font(.title3)
                Text(current.weather.first?.description.capitalized ?? "-")
                    .font(.subheadline)
            }
            
            Divider().padding(.vertical, 8)
            
            Text("Next Forecasts")
                .font(.headline)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(forecast.list.prefix(8)) { item in
                        VStack {
                            Text(Date(timeIntervalSince1970: item.dt), style: .time)
                            Text("\(Int(item.main.temp))°C")
                            if let icon = item.weather.first?.icon {
                                AsyncImage(
                                    url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
                                ) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
    }
}

//
//import SwiftUI
//
//struct WeatherView: View {
//    
//    var openWeatherResponse: OpenWeatherResponse
//    
//    // FormattedWeather를 사용하여 데이터에 쉽게 접근합니다.
//    private var formattedData: FormattedWeather {
//        FormattedWeather(response: openWeatherResponse)
//    }
//    
//    // 아이콘 리스트는 그대로 사용합니다.
//    // FormattedWeather의 weatherCondition 필드 (예: "Clear", "Clouds")를 사용합니다.
//    private let iconList = [
//        "Clear": "☀️",
//        "Clouds": "☁️",
//        "Mist": "🌫️", // Mist 아이콘 변경 (기존 "☁️"에서 좀 더 안개 느낌으로)
//        "Haze": "🌫️", // Haze에 대한 아이콘 추가
//        "Fog": "🌫️",  // Fog에 대한 아이콘 추가
//        "": "?",
//        "Drizzle": "🌧",
//        "Thunderstorm": "⛈",
//        "Rain": "🌧",
//        "Snow": "🌨",
//        "Smoke": "💨", // Smoke 아이콘 추가
//        // 필요에 따라 OpenWeatherMap의 'main' 조건에 따라 아이콘 추가 가능
//        // 예: "Ash", "Squall", "Tornado"
//    ]
//    
//    var body: some View {
//        VStack {
//            // 위치 이름 표시 (FormattedWeather 사용)
//            Text(formattedData.locationName)
//                .font(.largeTitle)
//                .padding()
//            
//            // 온도 표시 (FormattedWeather의 temperatureString 사용, 예: "25°C")
//            Text(formattedData.temperatureString()) // 기본값은 섭씨입니다. 화씨로 바꾸려면 temperatureString(unit: "F")
//                .font(.system(size: 75))
//                .bold()
//            
//            // 날씨 아이콘 표시 (FormattedWeather 사용)
//            Text(iconList[formattedData.weatherCondition] ?? iconList[""]!) // 기본 아이콘 "?"
//                .font(.largeTitle)
//                .padding()
//            
//            // 날씨 상세 설명 표시 (FormattedWeather 사용)
//            Text(formattedData.weatherDescription) // 예: "Moderate rain"
//                .font(.title) // 기존 largeTitle에서 title로 약간 줄여 가독성 향상 고려
//                .padding()
//            
//            // 습도 표시 (FormattedWeather 사용)
//            Text("Humidity: \(formattedData.humidity)%")
//                .font(.title2) // 기존 largeTitle에서 title2로 조정
//                .padding()
//            
//            // (추가 정보 예시) 체감 온도
//            Text("Feels like: \(Int(formattedData.feelsLikeCelsius))°C")
//                 .font(.title3)
//                 .padding(.bottom)
//
//            // (추가 정보 예시) 풍속 정보 (옵셔널이므로 확인 후 표시)
//            if let windSpeed = formattedData.windSpeed {
//                 Text("Wind: \(String(format: "%.1f", windSpeed)) m/s")
//                     .font(.title3)
//            }
//        }
//    }
//}
