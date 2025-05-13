//
//  BotSponsorList.swift
//  Space S
//
//  Created by 김재현 on 5/12/25.
//

//
//import SwiftUI
//
//struct SponsorListView: View {
//    @StateObject private var sponsorList = OrderSponsorList()
//
//    var body: some View {
//        List(sponsorList.sponsors) { sponsor in
//            VStack(alignment: .leading) {
//                Text(sponsor.name).font(.headline)
//                Text("Price: \(sponsor.price)")
//                Text("Delivery: \(sponsor.deliveryBenefit)")
//                Text("Dividend: \(sponsor.dividend)")
//            }
//        }
//    }
//}

import Foundation

// 데이터 모델 정의
struct Sponsorship: Identifiable, Codable {
    let name: String
    let price: String
    let deliveryBenefit: String
    let dividend: String
    let id: String
}

// ObservableObject 클래스
class OrderSponsorList: ObservableObject {
    @Published var sponsors: [Sponsorship] = []

    init() {
        loadSponsors()
    }

    private func loadSponsors() {
        guard let url = Bundle.main.url(forResource: "bot_order_sponsor_list", withExtension: "plist"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ Failed to load bot_order_sponsor_list.plist")
            return
        }

        do {
            let decoder = PropertyListDecoder()
            sponsors = try decoder.decode([Sponsorship].self, from: data)
        } catch {
            print("❌ Failed to decode plist: \(error.localizedDescription)")
        }
    }
}
