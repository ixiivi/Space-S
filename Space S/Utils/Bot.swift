//
//  BotSpec.swift
//  Space S
//
//  Created by 김재현 on 5/11/25.
//
//
//import Foundation
//
//public struct BotSpec: Codable {
//    public let model: String
//    public let price: String
//    public let estimatedDelivery: String
//    public let shipping_cost: String
//    public let hardware: Hardware
//    public let features: Features
//    public let physical: Physical
//    public let warranty: String
//
//    public struct Hardware: Codable {
//        public let cpu: String
//        public let ram: String
//        public let batteryLife: String
//    }
//
//    public struct Features: Codable {
//        public let sensors: [String]
//        public let aiCapabilities: String
//        public let mobility: String
//    }
//
//    public struct Physical: Codable {
//        public let weight: String
//        public let dimensions: String
//        public let material: String
//    }
//
//    public enum CodingKeys: String, CodingKey {
//        case model, price, estimatedDelivery, shipping_cost, hardware, features, physical, warranty
//    }
//
//    public static func loadSpecs() -> [String: BotSpec]? {
//        guard let url = Bundle.main.url(forResource: "bot_spec", withExtension: "plist") else {
//            Logger.logError("bot_spec.plist not found in bundle")
//            return nil
//        }
//
//        do {
//            let data = try Data(contentsOf: url)
//            let decoder = PropertyListDecoder()
//            let specs = try decoder.decode([String: BotSpec].self, from: data)
//            Logger.logInfo("Loaded bot specs: \(specs.keys)")
//            return specs
//        } catch {
//            Logger.logError("Failed to decode bot_spec.plist: \(error)")
//            return nil
//        }
//    }
//}


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
    @Published var physical: Physical = Physical(weight: "", dimensions: "", material: "")
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

