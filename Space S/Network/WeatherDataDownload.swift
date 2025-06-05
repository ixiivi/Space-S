//
//  WeatherService.swift
//  NewWeather
//
//  Created by 김형관 on 2023/04/25.
//

import Foundation
import CoreLocation

class WeatherDataDownload: ObservableObject {
    private let apiKey: String?
    
    enum WeatherError: Error {
        case invalidURL
        case requestFailed(Error)
        case decodingFailed
        case apiKeyMissing
    }
    
    init() {
        // EnvHelper를 사용하여 .env 파일에서 API 키 로드
        self.apiKey = EnvHelper.getVariable(named: "OPENWEATHER_API_KEY")
        
        if self.apiKey == nil {
            print("경고: OPENWEATHER_API_KEY가 .env 파일에 설정되어 있지 않거나 파일을 읽을 수 없습니다. 날씨 기능을 사용할 수 없습니다.")
            // 여기서 fatalError()를 발생시키거나, 사용자에게 알림을 표시하는 등의 처리를 할 수 있습니다.
        }
    }
    
    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        guard let currentApiKey = self.apiKey, !currentApiKey.isEmpty else {
            print("오류: API 키가 설정되지 않았습니다.")
            throw WeatherError.apiKeyMissing
        }
        
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(currentApiKey)&units=metric"
        
        guard let url = URL(string: urlStr) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // JSON 디코딩 에러를 더 명확하게 잡기 위한 do-catch 블록
            do {
                return try JSONDecoder().decode(ForecastResponse.self, from: data)
            } catch {
                print("JSON 디코딩 실패: \(error)")
                throw WeatherError.decodingFailed
            }
        } catch let error as WeatherError { // 이미 WeatherError 타입인 경우 그대로 throw
            throw error
        } catch { // 그 외 URLSession 에러 등
            print("데이터 요청 실패: \(error)")
            throw WeatherError.requestFailed(error)
        }
    }
}
