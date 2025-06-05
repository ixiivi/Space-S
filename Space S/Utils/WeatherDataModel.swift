import Foundation

// MARK: - 현재 날씨 API 응답 모델 (기존 유지)

struct OpenWeatherResponse: Decodable {
    let coord: Coord
    let weather: [WeatherInfo] // 현재 날씨에 대한 정보 (배열이지만 보통 첫 번째 요소 사용)
    let base: String
    let main: MainWeather // 현재 주요 날씨 정보 (온도, 습도 등)
    let visibility: Int
    let wind: WindInfo?
    let rain: RainInfo?
    let clouds: CloudsInfo?
    let dt: TimeInterval // 데이터 계산 시간, Unix, UTC
    let sys: SysInfo?
    let timezone: Int // UTC로부터의 시간차 (초 단위)
    let id: Int // 도시 ID
    let name: String // 도시 이름
    let cod: Int
}

struct Coord: Decodable {
    let lon: Double
    let lat: Double
}

struct WeatherInfo: Decodable, Identifiable {
    let id: Int // 날씨 상태 ID
    let main: String // 주요 날씨 (예: "Rain", "Clouds")
    let description: String // 날씨 설명 (예: "moderate rain")
    let icon: String // 날씨 아이콘 ID
}

struct MainWeather: Decodable { // 'Weather'에서 이름 변경 (Swift의 Weather와 충돌 방지)
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
    let sea_level: Int?
    let grnd_level: Int?
}

struct WindInfo: Decodable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}

struct RainInfo: Decodable {
    let lastHour: Double?
    enum CodingKeys: String, CodingKey {
        case lastHour = "1h" // API 응답의 "1h" 키에 매핑
    }
}

struct CloudsInfo: Decodable {
    let all: Int // 구름 양 (%)
}

struct SysInfo: Decodable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: TimeInterval? // 일출 시간, Unix, UTC
    let sunset: TimeInterval?  // 일몰 시간, Unix, UTC
}

// MARK: - One Call API 3.0 (주간/일별 예보 포함) 응답 모델

// One Call API의 최상위 응답 구조체
struct OneCallResponse: Decodable {
    let lat: Double
    let lon: Double
    let timezone: String        // 시간대 이름 (예: "America/Chicago")
    let timezone_offset: Int    // UTC로부터의 시간차 (초 단위)
    let current: CurrentWeather? // 현재 날씨 (One Call API에도 포함됨, 기존 OpenWeatherResponse와 유사)
    // let minutely: [MinutelyForecast]? // 분별 예보 (필요시 추가)
    // let hourly: [HourlyForecast]?     // 시간별 예보 (필요시 추가)
    let daily: [DailyForecast]?       // 일별 예보 (이것이 주간 예보에 해당)
    // let alerts: [WeatherAlert]?       // 날씨 알림 (필요시 추가)
}

// One Call API 내의 현재 날씨 정보
struct CurrentWeather: Decodable {
    let dt: TimeInterval
    let sunrise: TimeInterval?
    let sunset: TimeInterval?
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double?
    let uvi: Double?
    let clouds: Int?
    let visibility: Int?
    let wind_speed: Double?
    let wind_deg: Int?
    let wind_gust: Double?
    let weather: [WeatherInfo] // WeatherInfo 재활용
    let rain: RainInfo?        // RainInfo 재활용 (현재 강수량)
    let snow: SnowInfo?        // SnowInfo (현재 강설량, 필요시 정의)
}

// 일별 예보 구조체 (주간 예보에 사용)
struct DailyForecast: Decodable, Identifiable {
    var id: TimeInterval { dt } // Identifiable을 위해 dt를 id로 사용
    let dt: TimeInterval        // 예보 날짜, Unix, UTC
    let sunrise: TimeInterval?
    let sunset: TimeInterval?
    let moonrise: TimeInterval?
    let moonset: TimeInterval?
    let moon_phase: Double?
    let summary: String?        // 해당 날짜의 날씨 요약 (OpenWeatherMap에서 제공 시)
    
    let temp: DailyTemp         // 일별 온도 (최저, 최고 등)
    let feels_like: DailyFeelsLike // 일별 체감 온도
    
    let pressure: Int
    let humidity: Int
    let dew_point: Double?
    let wind_speed: Double?
    let wind_deg: Int?
    let wind_gust: Double?
    let weather: [WeatherInfo]  // WeatherInfo 재활용 (해당 날짜의 날씨 정보)
    let clouds: Int?
    let pop: Double?            // 강수 확률 (Probability of Precipitation, 0과 1 사이)
    let rain: Double?           // 강수량 (mm, 없을 수 있음)
    let snow: Double?           // 강설량 (mm, 없을 수 있음)
    let uvi: Double?
}

struct DailyTemp: Decodable {
    let day: Double?
    let min: Double?            // 일일 최저 온도
    let max: Double?            // 일일 최고 온도
    let night: Double?
    let eve: Double?
    let morn: Double?
}

struct DailyFeelsLike: Decodable {
    let day: Double?
    let night: Double?
    let eve: Double?
    let morn: Double?
}

// 필요에 따라 SnowInfo, MinutelyForecast, HourlyForecast, WeatherAlert 구조체 추가 가능
struct SnowInfo: Decodable {
    let lastHour: Double?
    enum CodingKeys: String, CodingKey {
        case lastHour = "1h"
    }
}


// MARK: - 데이터 포매팅 헬퍼 (기존 FormattedWeather 확장 또는 새로운 것 생성 가능)

// 기존 FormattedWeather는 OpenWeatherResponse (현재 날씨)를 위해 유지하고,
// 주간 예보를 위한 새로운 포매팅 구조체를 만들거나, FormattedWeather를 확장할 수 있습니다.
// 여기서는 기존 FormattedWeather를 참고용으로 남겨둡니다.

public struct FormattedWeather {
    let locationName: String
    let temperatureKelvin: Double
    let temperatureCelsius: Double
    let temperatureFahrenheit: Double
    let feelsLikeKelvin: Double
    let feelsLikeCelsius: Double
    let weatherCondition: String // 예: "Rain"
    let weatherDescription: String // 예: "moderate rain"
    let iconCode: String
    let humidity: Int
    let windSpeed: Double?
    let windDirectionDegrees: Int?
    let pressure: Int
    let visibilityKm: Double?
    let sunriseTime: String?
    let sunsetTime: String?

    // 이니셜라이저를 OpenWeatherResponse (현재 날씨용)과 OneCallResponse.CurrentWeather (OneCall API의 현재 날씨용)
    // 두 가지 경우 모두 처리할 수 있도록 수정하거나, 별도의 FormattedCurrentWeather를 만들 수 있습니다.
    
    // OpenWeatherResponse (기존 현재 날씨 API) 용 이니셜라이저
    init(response: OpenWeatherResponse) {
        self.locationName = response.name
        self.temperatureKelvin = response.main.temp // API가 이미 섭씨(units=metric)로 제공 가정
        self.temperatureCelsius = response.main.temp
        self.temperatureFahrenheit = (response.main.temp * 9/5) + 32
        
        self.feelsLikeKelvin = response.main.feels_like
        self.feelsLikeCelsius = response.main.feels_like
        
        self.weatherCondition = response.weather.first?.main ?? "N/A"
        self.weatherDescription = response.weather.first?.description.capitalized ?? "N/A"
        self.iconCode = response.weather.first?.icon ?? ""
        
        self.humidity = response.main.humidity
        self.windSpeed = response.wind?.speed
        self.windDirectionDegrees = response.wind?.deg
        self.pressure = response.main.pressure
        self.visibilityKm = Double(response.visibility) / 1000.0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let timezoneOffset = TimeZone(secondsFromGMT: response.timezone) {
            dateFormatter.timeZone = timezoneOffset
        }

        if let sunriseTimestamp = response.sys?.sunrise {
            self.sunriseTime = dateFormatter.string(from: Date(timeIntervalSince1970: sunriseTimestamp))
        } else {
            self.sunriseTime = nil
        }

        if let sunsetTimestamp = response.sys?.sunset {
            self.sunsetTime = dateFormatter.string(from: Date(timeIntervalSince1970: sunsetTimestamp))
        } else {
            self.sunsetTime = nil
        }
    }
    
    // OneCallResponse.CurrentWeather (OneCall API의 현재 날씨) 용 이니셜라이저 (추가)
    init?(currentWeather: CurrentWeather?, locationName: String, timezoneOffsetSeconds: Int) {
        guard let current = currentWeather else { return nil }
        
        self.locationName = locationName // OneCallResponse에서 가져온 도시 이름 또는 위경도 기반 이름
        self.temperatureKelvin = current.temp // API가 이미 섭씨(units=metric)로 제공 가정
        self.temperatureCelsius = current.temp
        self.temperatureFahrenheit = (current.temp * 9/5) + 32
        
        self.feelsLikeKelvin = current.feels_like
        self.feelsLikeCelsius = current.feels_like
        
        self.weatherCondition = current.weather.first?.main ?? "N/A"
        self.weatherDescription = current.weather.first?.description.capitalized ?? "N/A"
        self.iconCode = current.weather.first?.icon ?? ""
        
        self.humidity = current.humidity
        self.windSpeed = current.wind_speed
        self.windDirectionDegrees = current.wind_deg
        self.pressure = current.pressure
        self.visibilityKm = current.visibility != nil ? Double(current.visibility!) / 1000.0 : nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let timezone = TimeZone(secondsFromGMT: timezoneOffsetSeconds) {
             dateFormatter.timeZone = timezone
        }

        if let sunriseTimestamp = current.sunrise {
            self.sunriseTime = dateFormatter.string(from: Date(timeIntervalSince1970: sunriseTimestamp))
        } else {
            self.sunriseTime = nil
        }

        if let sunsetTimestamp = current.sunset {
            self.sunsetTime = dateFormatter.string(from: Date(timeIntervalSince1970: sunsetTimestamp))
        } else {
            self.sunsetTime = nil
        }
    }


    func temperatureString(unit: String = "C") -> String {
        switch unit.uppercased() {
        case "F":
            return String(format: "%.0f°F", temperatureFahrenheit)
        default: // Celsius
            return String(format: "%.0f°C", temperatureCelsius)
        }
    }
}

// FormattedDailyForecast - 일별 예보 데이터를 UI에 표시하기 쉽게 변환
public struct FormattedDailyForecast: Identifiable {
    public var id: TimeInterval // DailyForecast의 dt와 동일하게 설정
    let date: Date              // 예보 날짜 (Date 객체)
    let dayOfWeek: String       // 요일 (예: "월")
    let shortDate: String       // 짧은 날짜 (예: "6/5")
    let tempMinCelsius: Int?
    let tempMaxCelsius: Int?
    let weatherCondition: String // 예: "Rain"
    let weatherDescription: String
    let iconCode: String        // 예: "10d" (OpenWeatherMap 아이콘 코드)
    let popFormatted: String?   // 강수 확률 (예: "30%")

    init(dailyForecast: DailyForecast, timezoneIdentifier: String?) {
        self.id = dailyForecast.dt
        self.date = Date(timeIntervalSince1970: dailyForecast.dt)
        
        let dateFormatter = DateFormatter()
        if let tzId = timezoneIdentifier, let timezone = TimeZone(identifier: tzId) {
            dateFormatter.timeZone = timezone
        } else {
            // 기본값으로 UTC 또는 현지 시간대 사용 (API 응답에 따라 적절히 선택)
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // 예시: UTC
        }

        dateFormatter.dateFormat = "E" // 요일 (예: "Mon")
        self.dayOfWeek = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "M/d" // 날짜 (예: "6/5")
        self.shortDate = dateFormatter.string(from: date)

        self.tempMinCelsius = dailyForecast.temp.min != nil ? Int(dailyForecast.temp.min!.rounded()) : nil
        self.tempMaxCelsius = dailyForecast.temp.max != nil ? Int(dailyForecast.temp.max!.rounded()) : nil
        
        self.weatherCondition = dailyForecast.weather.first?.main ?? "N/A"
        self.weatherDescription = dailyForecast.weather.first?.description.capitalized ?? "N/A"
        self.iconCode = dailyForecast.weather.first?.icon ?? "01d" // 기본 아이콘 코드
        
        if let pop = dailyForecast.pop {
            self.popFormatted = "\(Int(pop * 100))%"
        } else {
            self.popFormatted = nil
        }
    }
    
    // OpenWeatherMap 아이콘 URL 생성 (예시)
    var iconURL: URL? {
        guard !iconCode.isEmpty else { return nil }
        return URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
    }
}
