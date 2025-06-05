//
//  User.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//

import Foundation
import SwiftData
@Model
class User {
    @Attribute(.unique) public var id: String
    public var name: String
    public var phoneNumber: String
    
    public var selectedBot: String?
    public var sponsor: String?
    public var waitList: Int = 6911211 //feches from server
    
    var productionStatus: String?
    var productionStartDate: Date?
    var estimatedProductionCompleteDate: Date?
    var productionDurationInDays: Int = 3
    var productionCapacity: Int = 5000 //feches from server
    
    // 발사장 배송 (지구)
    var shippingToLaunchSiteStatus: String?
    var launchSiteLocation: String?
    var estimatedArrivalAtLaunchSiteDate: Date?
    
    // 발사 단계
    var targetLaunchWindowStart: Date?
    var targetLaunchWindowEnd: Date?
    var launchStatus: String?
    var launchVehicleID: String?
    var actualLaunchDate: Date?
    
    // 행성 간 이동 단계
    var interplanetaryTransitStatus: String?
    var currentTrajectoryData: String?
    var estimatedArrivalAtMarsDate: Date?
    
    // 화성 착륙 및 배치 단계
    var marsLandingSite: String?
    var landingStatus: String?
    var actualLandingDate: Date?
    
    // 기타
    var lastDeliveryUpdate: Date?
    var deliveryUpdateLog: [String]?
    
    // createdAt 필드 추가 (정렬 및 참조용)
    var createdAt: Date = Date()
    
    init(id: String, name: String, phoneNumber: String) {
        self.id = id.lowercased()
        self.name = name
        self.phoneNumber = phoneNumber
        self.createdAt = Date()
    }
    
    public func orderFinish(selectedBot: String, sponsor: String) {
        self.selectedBot = selectedBot
        self.sponsor = sponsor
    }
    
    public func reduceWaitList(num: Int) {
        self.waitList -= num
    }
    
    var isFullySetup: Bool {
        let basicInfoComplete = !id.isEmpty && !name.isEmpty && !phoneNumber.isEmpty
        let botSelected = selectedBot != nil && !(selectedBot ?? "").isEmpty
        if basicInfoComplete && botSelected {
            return true
        }
        return false
    }
}
