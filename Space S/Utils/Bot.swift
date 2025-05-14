//
//  BotSpec.swift
//  Space S
//
//  Created by 김재현 on 5/11/25.
//
//

//** How to use. **
//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var bot = Bot(modelName: "Gen5")!
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Model: \(bot.model)")
//            Text("Price: \(bot.price)")
//            Text("CPU: \(bot.hardware.cpu)")
//            Text("AI: \(bot.features.aiCapabilities)")
//            Text("Weight: \(bot.physical.weight)")
//            Text("Warranty: \(bot.warranty)")
//        }
//        .padding()
//    }
//}


import Foundation

class Bot: ObservableObject {
    struct Hardware: Codable {
        var cpu: String
        var ram: String
        var batteryLife: String
    }

    struct Features: Codable {
        var sensors: [String]
        var aiCapabilities: String
        var mobility: String
    }

    struct Physical: Codable {
        var hand_dof: String
        var payload: String
        var height: String
        var weight: String
        var dimensions: String
        var material: String
    }

    @Published var model: String = ""
    @Published var price: String = ""
    @Published var shippingCost: String = ""
    @Published var estimatedDelivery: String = ""
    @Published var hardware: Hardware = Hardware(cpu: "", ram: "", batteryLife: "")
    @Published var features: Features = Features(sensors: [], aiCapabilities: "", mobility: "")
    @Published var physical: Physical = Physical(hand_dof:"", payload:"", height:"", weight: "", dimensions: "", material: "")
    @Published var warranty: String = ""

    init?(modelName: String) {
        guard let url = Bundle.main.url(forResource: "bot_spec", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let root = plist as? [String: Any],
              let modelDict = root[modelName] as? [String: Any] else {
            Logger.logError("Failed to load bot specification for model: \(modelName)")
            return nil
        }

        self.model = modelDict["model"] as? String ?? ""
        self.price = modelDict["price"] as? String ?? ""
        self.shippingCost = modelDict["shipping_cost"] as? String ?? ""
        self.estimatedDelivery = modelDict["estimatedDelivery"] as? String ?? ""

        if let hw = modelDict["hardware"] as? [String: String] {
            self.hardware = Hardware(
                cpu: hw["cpu"] ?? "",
                ram: hw["ram"] ?? "",
                batteryLife: hw["batteryLife"] ?? ""
            )
        }

        if let ft = modelDict["features"] as? [String: Any] {
            self.features = Features(
                sensors: ft["sensors"] as? [String] ?? [],
                aiCapabilities: ft["aiCapabilities"] as? String ?? "",
                mobility: ft["mobility"] as? String ?? ""
            )
        }

        if let ph = modelDict["physical"] as? [String: String] {
            self.physical = Physical(
                hand_dof:ph["hand_dof"] ?? "",
                payload: ph["payload"] ?? "",
                height: ph["height"] ?? "",
                weight: ph["weight"] ?? "",
                dimensions: ph["dimensions"] ?? "",
                material: ph["material"] ?? ""
            )
        }

        self.warranty = modelDict["warranty"] as? String ?? ""
        
        // 모든 필수 필드가 비어있지 않은지 확인
        guard !self.model.isEmpty && !self.price.isEmpty && !self.estimatedDelivery.isEmpty else {
            Logger.logError("Bot specification for model \(modelName) is incomplete")
            return nil
        }
    }
}

