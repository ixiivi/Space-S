//
//  EnvHelper.swift
//  Space S
//
//  Created by 김재현 on 6/6/25.
//

import Foundation

struct EnvHelper {
    static func getVariable(named variableName: String) -> String? {
        // 1. 번들된 .env 파일 경로 찾기
        guard let envFilePath = Bundle.main.path(forResource: ".env", ofType: nil) else {
            print("오류: 번들에서 .env 파일을 찾을 수 없습니다.")
            return nil
        }

        do {
            // 2. .env 파일 내용 읽기
            let envFileContents = try String(contentsOfFile: envFilePath)
            
            // 3. 파일 내용을 줄 단위로 분리하고, 각 줄에서 키-값 파싱
            let lines = envFileContents.split { $0.isNewline }
            for line in lines {
                // 주석(#으로 시작)이거나 빈 줄은 건너뛰기
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.isEmpty || trimmedLine.starts(with: "#") {
                    continue
                }
                
                let parts = trimmedLine.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    let key = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if key == variableName {
                        // 따옴표로 감싸진 값 처리 (선택 사항)
                        if value.hasPrefix("\"") && value.hasSuffix("\"") {
                            return String(value.dropFirst().dropLast())
                        }
                        if value.hasPrefix("'") && value.hasSuffix("'") {
                            return String(value.dropFirst().dropLast())
                        }
                        return value
                    }
                }
            }
            print("오류: .env 파일에서 '\(variableName)' 변수를 찾을 수 없습니다.")
            return nil
        } catch {
            print("오류: .env 파일 읽기 실패 - \(error)")
            return nil
        }
    }
}
