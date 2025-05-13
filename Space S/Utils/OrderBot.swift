//
//  RobotOrder.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//
//
//import Foundation
//
//public class RobotOrder: ObservableObject, Codable {
//    @Published public var model: String
//    @Published public var robotPrice: String
//    @Published public var shippingCost: String
//    @Published public var estimatedDelivery: String
//    @Published public var sponsorship: String?
//    @Published public var sponsorshipSpeedup: String?
//    @Published public var newDelivery: String?
//
//    public enum CodingKeys: String, CodingKey {
//        case model, robotPrice, shippingCost, estimatedDelivery, sponsorship, sponsorshipSpeedup, newDelivery
//    }
//
//    public init(bot_spec: BotSpec) {
//        self.model = bot_spec.model
//        self.robotPrice = bot_spec.price
//        self.shippingCost = bot_spec.shipping_cost
//        self.estimatedDelivery = bot_spec.estimatedDelivery
//        self.sponsorship = nil
//        self.sponsorshipSpeedup = nil
//        self.newDelivery = nil
//    }
//
//    public func applySponsorship(sponsorship: String, speedup: String) {
//        self.sponsorship = sponsorship
//        self.sponsorshipSpeedup = speedup
//        self.newDelivery = calculateNewDelivery(speedup: speedup)
//    }
//
//    private func calculateNewDelivery(speedup: String) -> String {
//        let months = Int(speedup.prefix(1)) ?? 0
//        let baseDate = model == "Gen6" ? "July 2026" : "January 2026"
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM yyyy"
//        if let date = formatter.date(from: baseDate) {
//            if let newDate = Calendar.current.date(byAdding: .month, value: -months, to: date) {
//                return formatter.string(from: newDate)
//            }
//        }
//        return estimatedDelivery // Fallback
//    }
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        model = try container.decode(String.self, forKey: .model)
//        robotPrice = try container.decode(String.self, forKey: .robotPrice)
//        shippingCost = try container.decode(String.self, forKey: .shippingCost)
//        estimatedDelivery = try container.decode(String.self, forKey: .estimatedDelivery)
//        sponsorship = try container.decodeIfPresent(String.self, forKey: .sponsorship)
//        sponsorshipSpeedup = try container.decodeIfPresent(String.self, forKey: .sponsorshipSpeedup)
//        newDelivery = try container.decodeIfPresent(String.self, forKey: .newDelivery)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(model, forKey: .model)
//        try container.encode(robotPrice, forKey: .robotPrice)
//        try container.encode(shippingCost, forKey: .shippingCost)
//        try container.encode(estimatedDelivery, forKey: .estimatedDelivery)
//        try container.encodeIfPresent(sponsorship, forKey: .sponsorship)
//        try container.encodeIfPresent(sponsorshipSpeedup, forKey: .sponsorshipSpeedup)
//        try container.encodeIfPresent(newDelivery, forKey: .newDelivery)
//    }
//}
