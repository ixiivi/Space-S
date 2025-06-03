//
//  LaunchScheduleLoader.swift
//  Space S
//
//  Created by HyunDo Song on 6/3/25.
//

import Foundation

struct LaunchSchedule: Codable {
    let launchDate: String
}

class LaunchScheduleLoader {
    static func loadLaunchDate() -> Date? {
        guard let url = Bundle.main.url(forResource: "launch_schedule", withExtension: "json") else {
            print("launch_schedule.json not found in bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(LaunchSchedule.self, from: data)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: decoded.launchDate)
        } catch {
            print("Failed to load launch schedule: \(error.localizedDescription)")
            return nil
        }
    }
}
