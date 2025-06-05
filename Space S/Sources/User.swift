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
    
    var productionStatus: String? // 예: "대기중", "생산중", "조립완료", "품질검사중", "생산완료"
    var estimatedProductionCompleteDate: Date? // 예상 생산 완료일
    
    // 발사장 배송 (지구)
    var shippingToLaunchSiteStatus: String? // 예: "생산지 출발", "운송중", "발사장 도착"
    var launchSiteLocation: String? // 예: "케이프 커내버럴", "스타베이스"
    var estimatedArrivalAtLaunchSiteDate: Date?// 발사장 예상 도착일
    
    // 발사 단계
    var targetLaunchWindowStart: Date?        // 목표 발사 기간 시작
    var targetLaunchWindowEnd: Date?          // 목표 발사 기간 종료
    var launchStatus: String?                 // 예: "발사 예정", "기상 악화로 대기", "발사됨"
    var launchVehicleID: String?              // 발사체 ID
    var actualLaunchDate: Date?               // 실제 발사일
    
    // 행성 간 이동 단계
    var interplanetaryTransitStatus: String?  // 예: "지구궤도이탈", "항행중", "화성접근중"
    var currentTrajectoryData: String?        // 현재 궤도 정보 (JSON 문자열 또는 식별자)
    var estimatedArrivalAtMarsDate: Date?     // 화성 예상 도착일 (동적으로 업데이트될 최종 배송 예상일)
    
    // 화성 착륙 및 배치 단계
    var marsLandingSite: String?              // 화성 착륙 지점
    var landingStatus: String?                // 예: "착륙 대기중", "착륙 성공", "배치중"
    var actualLandingDate: Date?              // 실제 착륙일
    
    // 기타
    var lastDeliveryUpdate: Date?             // 마지막 배송 정보 업데이트 시간
    var deliveryUpdateLog: [String]?          // 배송 관련 주요 이벤트 로그 (배열)
    
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
