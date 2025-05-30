//
//  Logger.swift
//  Space S
//
//  Created by 김재현 on 5/9/25.
//

//**Logger 사용법**

//Logger.logInfo("App started successfully.")
//Logger.logError("An error occurred while fetching data.")

//**터미널에서 log 폴더 찾기
//1. xcrun simctl list devices
//2. 디바이스 ID 확인
//3.find ~/Library/Developer/CoreSimulator/Devices/<실제DeviceID>/data/Containers/Data/Application -name "app.log"


import Foundation

enum LogType: String {
    case info = "INFO"
    case error = "ERROR"
}

class Logger {
    
    // 로그 파일 경로
    static let appLogFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs/app.log")
    static let errorLogFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs/error.log")
    
    // 로그 파일을 열어서 쓸 수 있는 함수
    private static func writeLog(message: String, logType: LogType) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)
        let logMessage = "[\(timestamp)] [\(logType.rawValue)] - \(message)\n"
        
        let logFileURL = logType == .error ? errorLogFile : appLogFile
        
        // 파일에 로그 메시지 추가
        do {
            if !FileManager.default.fileExists(atPath: logFileURL.path) {
                // 로그 파일이 없으면 생성
                try FileManager.default.createDirectory(at: logFileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try logMessage.write(to: logFileURL, atomically: true, encoding: .utf8)
            } else {
                let fileHandle = try FileHandle(forWritingTo: logFileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(logMessage.data(using: .utf8)!)
                fileHandle.closeFile()
            }
        } catch {
            print("Error writing log to file: \(error)")
        }
    }
    
    // 정보 로그
    static func logInfo(_ message: String) {
        writeLog(message: message, logType: .info)
    }
    
    // 에러 로그
    static func logError(_ message: String) {
        writeLog(message: message, logType: .error)
    }
}
