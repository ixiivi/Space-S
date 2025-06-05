//
//  WeatherService.swift
//  NewWeather
//
//  Created by 김형관 on 2023/04/25.
//
import Foundation
import CoreLocation // CLLocationCoordinate2D 사용을 위해 import

class WeatherDataDownload {
    
    // OpenWeatherMap API 키 (기존과 동일)
    private let apiKey = "1bfc4008e2f3db1a9f06cd4fe4626d57"
    
    // 텍사스 오스틴의 고정 위치 정보 (주간 예보 API에 사용)
    // 실제 앱에서는 LocationManager를 통해 동적으로 받거나, 사용자가 선택한 위치를 사용할 수 있습니다.
    private let austinLatitude: Double = 30.2672
    private let austinLongitude: Double = -97.7431
    
    // 에러 처리를 위한 사용자 정의 에러 타입
    enum WeatherError: Error {
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case decodingError(Error)
        case dataNotFound
    }

    /**
     지정된 도시 이름으로 현재 날씨 정보를 가져옵니다. (기존 함수 유지 및 개선)
     - Parameter cityName: 날씨 정보를 가져올 도시 이름 (예: "Austin,US"). 기본값은 "Austin,US"입니다.
     - Returns: `OpenWeatherResponse` 객체.
     - Throws: `WeatherError` 타입의 에러를 발생시킬 수 있습니다.
     */
    func getCurrentWeather(cityName: String = "Austin,US") async throws -> OpenWeatherResponse {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"
        
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else {
            throw WeatherError.invalidURL
        }
        
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                // 응답 코드가 200이 아닌 경우, 응답 내용을 파악하기 위해 data를 문자열로 변환 시도
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("Error: Invalid HTTP response. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0), Body: \(responseBody)")
                throw WeatherError.invalidResponse
            }
            
            let decodedData = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            return decodedData
        } catch let error as DecodingError {
            print("Decoding Error: \(error)")
            throw WeatherError.decodingError(error)
        } catch {
            print("Network Error: \(error)")
            throw WeatherError.networkError(error)
        }
    }

    /**
     지정된 위도와 경도로 8일치 일별 예보를 포함한 One Call API 3.0 데이터를 가져옵니다.
     - Parameters:
        - latitude: 예보를 가져올 위치의 위도.
        - longitude: 예보를 가져올 위치의 경도.
     - Returns: `OneCallResponse` 객체.
     - Throws: `WeatherError` 타입의 에러를 발생시킬 수 있습니다.
     */
    func getDailyForecasts(latitude: Double, longitude: Double) async throws -> OneCallResponse {
        // One Call API 3.0 엔드포인트
        // exclude 파라미터를 사용하여 현재, 분별, 시간별, 알림 데이터를 제외하고 일별 예보만 가져오도록 할 수 있습니다.
        // 필요에 따라 exclude 내용을 조절하세요. (예: 현재 날씨도 받고 싶으면 "current" 제외)
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,alerts&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("Error: Invalid HTTP response for daily forecast. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0), Body: \(responseBody)")
                throw WeatherError.invalidResponse
            }
            
            // JSON 디코더 설정 (날짜/시간 처리 등 필요시 추가 설정 가능)
            let decoder = JSONDecoder()
            // 예: decoder.dateDecodingStrategy = .secondsSince1970 (API 응답이 Unix timestamp인 경우)
            // WeatherDataModel.swift의 TimeInterval 타입은 이미 Unix timestamp와 호환됩니다.

            let decodedData = try decoder.decode(OneCallResponse.self, from: data)
            
            // 일별 예보 데이터가 있는지 확인 (선택적)
            guard decodedData.daily != nil, !(decodedData.daily?.isEmpty ?? true) else {
                print("Data Not Found: Daily forecast data is missing or empty in the response.")
                throw WeatherError.dataNotFound
            }
            
            return decodedData
        } catch let error as DecodingError {
            print("Decoding Error for daily forecast: \(error)")
            // 디버깅을 위해 어떤 부분이 디코딩에 실패했는지 자세히 출력
            switch error {
            case .typeMismatch(let key, let context):
                print("Type mismatch for key \(key) in context: \(context.debugDescription)")
                print("CodingPath: \(context.codingPath)")
            case .valueNotFound(let key, let context):
                print("Value not found for key \(key) in context: \(context.debugDescription)")
                print("CodingPath: \(context.codingPath)")
            case .keyNotFound(let key, let context):
                print("Key not found: \(key) in context: \(context.debugDescription)")
                print("CodingPath: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted in context: \(context.debugDescription)")
                print("CodingPath: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error: \(error.localizedDescription)")
            }
            throw WeatherError.decodingError(error)
        } catch {
            print("Network Error for daily forecast: \(error)")
            throw WeatherError.networkError(error)
        }
    }
    
    /**
     텍사스 오스틴의 현재 날씨와 주간(8일) 예보를 함께 가져오는 편의 함수입니다.
     - Returns: (현재 날씨: `OpenWeatherResponse?`, 주간 예보: `OneCallResponse?`, 에러: `Error?`) 튜플.
                튜플의 각 요소는 성공/실패 여부에 따라 nil이 될 수 있습니다.
                더 나은 방법은 각 함수를 개별적으로 호출하고 결과를 조합하는 것입니다.
                여기서는 두 정보를 한 번에 가져오는 예시로 제공합니다.
                실제 사용 시에는 TaskGroup 등을 사용하여 병렬로 호출하는 것을 고려할 수 있습니다.
     */
    func fetchAustinWeatherAndForecast() async -> (current: OpenWeatherResponse?, forecast: OneCallResponse?, error: Error?) {
        var currentWeatherData: OpenWeatherResponse?
        var forecastData: OneCallResponse?
        var encounteredError: Error?

        // TaskGroup을 사용하여 두 API 호출을 병렬로 실행 (선택적 최적화)
        // 여기서는 순차적으로 호출하는 간단한 예시를 보여드립니다.
        // 더 강력한 동시성 처리가 필요하면 TaskGroup을 고려하세요.

        do {
            print("Fetching current weather for Austin...")
            currentWeatherData = try await getCurrentWeather(cityName: "Austin,US")
            print("Successfully fetched current weather.")
        } catch {
            print("Failed to fetch current weather: \(error)")
            encounteredError = error
            // 현재 날씨 실패 시 주간 예보도 가져오지 않도록 하려면 여기서 return 할 수 있습니다.
            // 또는 부분적인 성공을 허용할 수 있습니다.
        }
        
        // 현재 날씨 가져오기에 성공했거나, 실패했더라도 주간 예보를 시도하고 싶다면 계속 진행
        // 여기서는 현재 날씨 에러가 발생하면 주간 예보는 시도하지 않고 반환합니다. (정책에 따라 변경 가능)
        if encounteredError != nil && currentWeatherData == nil {
             // return (currentWeatherData, forecastData, encounteredError) // 현재 날씨 실패 시 즉시 반환
        }

        do {
            print("Fetching weekly forecast for Austin...")
            // OneCall API는 도시 이름 대신 위도/경도를 사용합니다.
            // getCurrentWeather에서 받은 coord 정보를 사용하거나, 고정된 오스틴 좌표를 사용합니다.
            let lat = currentWeatherData?.coord.lat ?? austinLatitude // 현재 날씨 응답에서 위도 사용, 없으면 고정값
            let lon = currentWeatherData?.coord.lon ?? austinLongitude // 현재 날씨 응답에서 경도 사용, 없으면 고정값
            
            forecastData = try await getDailyForecasts(latitude: lat, longitude: lon)
            print("Successfully fetched weekly forecast.")
        } catch {
            print("Failed to fetch weekly forecast: \(error)")
            // 여러 에러가 발생했을 경우, 어떤 에러를 우선적으로 반환할지 결정해야 합니다.
            // 여기서는 마지막 에러로 덮어씁니다.
            encounteredError = error
        }
        
        return (currentWeatherData, forecastData, encounteredError)
    }
}
//```
//
//**주요 변경 및 추가 사항:**
//
//1.  **`austinLatitude`, `austinLongitude` 추가**: 텍사스 오스틴의 위도와 경도를 상수로 정의했습니다. `getDailyForecasts` 함수에서 이 값을 사용합니다.
//2.  **`WeatherError` 열거형 추가**: API 호출과 관련된 다양한 에러 상황을 정의하여 좀 더 명확한 에러 처리가 가능하도록 했습니다.
//3.  **`getCurrentWeather` 함수 개선**:
//    * `fatalError` 대신 `throw WeatherError`를 사용하여 에러를 반환하도록 수정했습니다.
//    * URL 인코딩을 추가하여 도시 이름에 공백 등이 포함될 경우를 대비했습니다.
//    * HTTP 응답 코드 및 디코딩 에러 발생 시 좀 더 자세한 정보를 출력하도록 개선했습니다.
//4.  **`getDailyForecasts(latitude:longitude:)` 함수 추가**:
//    * OpenWeatherMap의 **One Call API 3.0**을 사용하여 특정 위도와 경도에 대한 날씨 정보를 가져옵니다.
//    * `exclude` 파라미터를 사용하여 일별 예보(`daily`) 외에 필요 없는 데이터(분별, 시간별, 알림)는 제외하도록 설정했습니다. (API 호출량 및 응답 크기 최적화)
//        * **중요**: One Call API 응답에는 `current` (현재 날씨) 필드도 포함되어 있으므로, `getCurrentWeather`를 별도로 호출하지 않고 이 함수 하나로 현재 날씨와 주간 예보를 모두 처리할 수도 있습니다. 요청에 따라 두 함수를 분리하여 유지했습니다.
//    * API 키와 단위(metric)는 기존과 동일하게 사용합니다.
//    * 에러 처리 로직을 `getCurrentWeather`와 유사하게 개선했습니다. 특히 `DecodingError` 발생 시 어떤 키에서 문제가 발생했는지 더 자세히 알 수 있도록 `switch` 문을 사용한 디버깅 정보를 추가했습니다.
//    * `daily` 데이터가 비어있는 경우 `WeatherError.dataNotFound`를 throw 하도록 추가했습니다.
//5.  **`fetchAustinWeatherAndForecast()` 함수 추가 (편의 함수, 선택적)**:
//    * 오스틴의 현재 날씨와 주간 예보를 한 번에 가져오는 예시 함수입니다.
//    * 내부적으로 `getCurrentWeather`와 `getDailyForecasts`를 순차적으로 호출합니다.
//    * 주간 예보를 가져올 때, `getCurrentWeather`에서 성공적으로 받아온 좌표를 사용하거나, 실패 시 미리 정의된 오스틴 좌표를 사용하도록 했습니다.
//    * 실제 앱에서는 `TaskGroup`을 사용하여 두 API 호출을 병렬로 처리하여 응답 시간을 단축하는 것을 고려할 수 있습니다. 이 예제에서는 단순화를 위해 순차 호출로 작성했습니다.
//    * 반환 값은 튜플 형태로, 각 데이터와 발생 가능성이 있는 에러를 포함합니다.
//
//이제 이 `WeatherDataDownload.swift` 파일을 사용하여 `EarthSideView.swift` (또는 관련 ViewModel)에서 현재 날씨와 주간 예보 데이터를 가져와 UI에 표시할 수 있습
