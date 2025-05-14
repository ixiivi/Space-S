////
////  User.swift
////  Space S
////
////  Created by 김재현 on 5/10/25.
////
//
//import Foundation
//
//public class User: ObservableObject, Codable {
//    @Published public var id: String
//    @Published public var name: String
//    @Published public var email: String
//    @Published public var createdAt: Date
//    @StateObject private var bot: Bot
//    @StateObject private var sponsor:OrderSponsorList
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, email, createdAt, orders
//    }
//
//    public init(id: String, name: String, email: String) {
//        self.id = id
//        self.name = name
//        self.email = email
//        self.createdAt = Date()
//    }
//
//    public func addOrder(_ order: RobotOrder) {
//        orders.append(order)
//        Logger.logInfo("Added order for \(order.model) to user \(id)")
//    }
//
//    public func clearOrders() {
//        orders.removeAll()
//        Logger.logInfo("Cleared all orders for user \(id)")
//    }
//
//    // Codable conformance
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        email = try container.decode(String.self, forKey: .email)
//        createdAt = try container.decode(Date.self, forKey: .createdAt)
//        orders = try container.decode([RobotOrder].self, forKey: .orders)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(name, forKey: .name)
//        try container.encode(email, forKey: .email)
//        try container.encode(createdAt, forKey: .createdAt)
//        try container.encode(orders, forKey: .orders)
//    }
//}
