//
//  LaunchDateGenerator.swift
//  Space S
//
//  Created by 김재현 on 6/4/25.
//

import Foundation

// JSON 파일에 저장될 각 발사 날짜 항목을 나타내는 구조체입니다.
// Codable을 준수하여 JSON 직렬화/역직렬화가 가능합니다.
struct LaunchDateEntry: Codable, Hashable, Identifiable {
    // Identifiable을 위한 id 프로퍼티, 날짜 문자열을 그대로 사용합니다.
    var id: String { date }
    let date: String // 날짜를 "yyyy-MM-dd" 형식의 문자열로 저장합니다.

    // 문자열로부터 Date 객체를 생성하는 편의 이니셜라이저입니다.
    // LaunchDateGenerator.dateFormatter를 사용합니다.
    init?(dateString: String) {
        guard LaunchDateGenerator.dateFormatter.date(from: dateString) != nil else {
            return nil // 유효하지 않은 날짜 형식이면 nil을 반환합니다.
        }
        self.date = dateString
    }

    // Date 객체로부터 LaunchDateEntry를 생성하는 편의 이니셜라이저입니다.
    // LaunchDateGenerator.dateFormatter를 사용합니다.
    init(date: Date) {
        self.date = LaunchDateGenerator.dateFormatter.string(from: date)
    }
}

class LaunchDateGenerator {

    // 날짜를 "yyyy-MM-dd" 형식으로 변환하고 파싱하기 위한 DateFormatter입니다.
    // UTC 시간대를 사용하여 시간대 문제를 방지합니다.
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC") // 일관성을 위해 UTC 사용
        return formatter
    }()

    /**
     지정된 시작 날짜부터 종료 날짜까지 매주 월요일, 수요일, 금요일에 해당하는 발사 날짜 배열을 생성합니다.
     - Parameters:
        - startDate: 발사 날짜 생성을 시작할 기준 날짜입니다.
        - endDate: 발사 날짜 생성을 종료할 기준 날짜입니다.
     - Returns: 생성된 Date 객체의 배열을 반환합니다.
     */
    static func generateLaunchDates(from startDate: Date, to endDate: Date) -> [Date] {
        var launchDates: [Date] = []
        let calendar = Calendar.current // 사용자의 현재 달력 설정을 사용합니다.
        
        // startDate를 해당 날짜의 시작 시간으로 정규화합니다.
        let startOfDay = calendar.startOfDay(for: startDate)
        var currentDate = startOfDay
        
        // currentDate가 endDate보다 작거나 같은 동안 반복합니다.
        while currentDate <= endDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            // 요일 구성 요소: 일요일=1, 월요일=2, 화요일=3, 수요일=4, 목요일=5, 금요일=6, 토요일=7
            if weekday == 2 || weekday == 4 || weekday == 6 { // 월요일, 수요일, 금요일인지 확인합니다.
                launchDates.append(currentDate)
            }
            
            // 다음 날짜로 이동합니다.
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                // currentDate가 유효하다면 이 경우는 발생하지 않아야 합니다.
                print("Error: Could not calculate the next day.")
                break
            }
            currentDate = nextDay
        }
        
        return launchDates
    }

    /**
     Date 객체 배열을 앱의 Documents 디렉토리에 JSON 파일로 저장합니다.
     날짜는 "yyyy-MM-dd" 형식의 문자열로 저장됩니다.
     - Parameters:
        - dates: 저장할 Date 객체의 배열입니다.
        - fileName: 저장할 JSON 파일의 이름입니다. 기본값은 "db.json"입니다.
     */
    static func saveLaunchDatesToJSON(dates: [Date], fileName: String = "launch_date_db.json") {
        let launchEntries = dates.map { LaunchDateEntry(date: $0) } // Date를 LaunchDateEntry로 변환합니다.
        let fileURL = getDocumentsDirectoryFileURL(for: fileName)

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // JSON을 읽기 쉽게 포맷합니다.
            let jsonData = try encoder.encode(launchEntries)
            try jsonData.write(to: fileURL, options: [.atomicWrite]) // 원자적으로 파일을 씁니다.
            print("Successfully saved launch dates to: \(fileURL.path)")
        } catch {
            print("Error saving launch dates to JSON: \(error.localizedDescription)")
        }
    }

    /**
     앱의 Documents 디렉토리에서 JSON 파일을 읽어 Date 객체 배열을 로드합니다.
     JSON 파일에는 날짜가 "yyyy-MM-dd" 형식의 문자열로 저장되어 있어야 합니다.
     - Parameter fileName: 로드할 JSON 파일의 이름입니다. 기본값은 "db.json"입니다.
     - Returns: 로드된 Date 객체의 배열을 반환합니다. 파일이 없거나 오류 발생 시 빈 배열을 반환합니다.
     */
    static func loadLaunchDatesFromJSON(fileName: String = "launch_date_db.json") -> [Date] {
        let fileURL = getDocumentsDirectoryFileURL(for: fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Launch dates file not found at: \(fileURL.path)")
            return [] // 파일이 없으면 빈 배열을 반환합니다.
        }

        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let launchEntries = try decoder.decode([LaunchDateEntry].self, from: jsonData)
            
            // LaunchDateEntry를 Date로 변환합니다. 유효하지 않은 날짜 문자열은 필터링합니다.
            let dates = launchEntries.compactMap { dateFormatter.date(from: $0.date) }
            print("Successfully loaded launch dates from: \(fileURL.path)")
            return dates
        } catch {
            print("Error loading launch dates from JSON: \(error.localizedDescription)")
            return [] // 오류 발생 시 빈 배열을 반환합니다.
        }
    }

    /**
     앱의 Documents 디렉토리 내 특정 파일의 URL을 반환하는 헬퍼 함수입니다.
     - Parameter fileName: 파일 이름입니다.
     - Returns: 해당 파일의 전체 URL을 반환합니다.
     */
    private static func getDocumentsDirectoryFileURL(for fileName: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }

    /**
     오늘부터 향후 2년간의 발사 날짜를 생성하고 JSON 파일로 저장하는 예제 함수입니다.
     이 함수는 `LoadingView`의 `onAppear` 등에서 호출될 수 있습니다.
     */
    static func generateAndSaveUpcomingLaunchDates(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let today = Date()
            guard let twoYearsFromNow = Calendar.current.date(byAdding: .year, value: 2, to: today) else {
                print("Error: Could not calculate the date two years from now.")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            print("Generating launch dates from \(dateFormatter.string(from: today)) to \(dateFormatter.string(from: twoYearsFromNow))")
            let generatedDates = generateLaunchDates(from: today, to: twoYearsFromNow)
            saveLaunchDatesToJSON(dates: generatedDates)
            
            // 완료 콜백
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}
