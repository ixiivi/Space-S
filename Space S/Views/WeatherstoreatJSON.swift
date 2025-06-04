//
//  weatherstore.swift
//  Space S
//
//  Created by snlcom on 6/1/25.
//

// 날씨 저장 기능 - 6.2까지 드리기

import SwiftUI

struct EarthSideView2: View {
    var user: User

    var body: some View {
        VStack {
            // 예시 UI
            Text("발사 날짜 보기")
        }
        .onAppear {
            saveLaunchDatesToJSONFileIfNeeded(for: user)
        }
    }
}

func saveLaunchDatesToJSONFileIfNeeded(for user: User) {
    let calendar = Calendar.current
    let today = Date()
    let weekday = calendar.component(.weekday, from: today) // 일요일이 1

    guard weekday == 1 else { return }

    let launchInfo = [
        "userID": user.id,
        "userName": user.name,
        "today": ISO8601DateFormatter().string(from: today),
        "estimatedProductionCompleteDate": user.estimatedProductionCompleteDate?.iso8601 ?? "nil",
        "estimatedArrivalAtMarsDate": user.estimatedArrivalAtMarsDate?.iso8601 ?? "nil"
    ]

    do {
        let data = try JSONSerialization.data(withJSONObject: launchInfo, options: .prettyPrinted)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("launchDates_\(Date().formatted(date: .numeric, time: .omitted)).json")
        
        try data.write(to: url)
        print("발사일정 저장완료: \(url)")
    } catch {
        print("JSON에 발사 일정 저장 실패: \(error)")
    }
}

extension Date {
    var iso8601: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

//일단 일요일만 저장하는 것으로 설정해놓음. 오류가 뜨긴 하는데 저건 잘 모르겠어요..//

