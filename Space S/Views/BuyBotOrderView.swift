//
//  BuyBotOrderView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//

import SwiftUI

public struct BuyBotOrderView: View {
    public let model: String
    @State private var showDelayInfo = false // For delay explanation popup
    @State private var showSponsorshipOptions = false // For sponsorship sheet
    @State private var sponsorshipSpeedup: Int? = nil // Tracks selected sponsorship speedup
    @State private var newDelivery: String? = nil // New delivery date after sponsorship
    @StateObject private var bot: Bot
    @StateObject private var sponsorList = OrderSponsorList()
    
    public init(model: String) {
        self.model = model
        // 기본 Bot 인스턴스 생성 (Gen6를 폴백으로 사용)
        let defaultBot = Bot(modelName: "Gen6")!
        _bot = StateObject(wrappedValue: Bot(modelName: model) ?? defaultBot)
    }
    // Robot prices and shipping details
    private var robotPrice: String { bot.price }
    private var shippingCost: String { bot.shippingCost }
    private var estimatedDelivery: String { bot.estimatedDelivery }
//    private var totalPriceString: String {
//            // Convert prices to Int, default to 0 if conversion fails
//            let robotPriceInt = convertPriceToInt(robotPrice) ?? 0
//            let shippingCostInt = convertPriceToInt(shippingCost) ?? 0
//            // Sum and format as string with "$"
//            let total = robotPriceInt + shippingCostInt
//            return "\(total)"
//        }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Dark background like BuyBotMainView

            ScrollView {
                VStack(spacing: 0) {
                    // Header with robot image and title
                    VStack(spacing: 16) {
                        Image(model)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                        Text("Optimus \(model)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("Your AI citizen is ready for Mars deployment.")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // Robot price and details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Order Summary")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        infoRow("Model", value: "Optimus \(model)")
                        infoRow("Price", value: "$" + robotPrice)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)

                    // Shipping information
                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Shipping Information")
//                            .font(.system(size: 24, weight: .bold))
//                            .foregroundColor(.white)
                        infoRow("Shipping Cost", value: "$" + shippingCost)
                        if let newDelivery = newDelivery, let sponsorshipSpeedup = sponsorshipSpeedup {
                            HStack {
                                Text("Estimated Delivery")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 150, alignment: .leading)
                                VStack{
                                    Text(estimatedDelivery)
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .strikethrough(true, color: .red)
                                    Text("\(newDelivery)")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        } else {
                            infoRow("Estimated Delivery", value: estimatedDelivery)
                        }
                        HStack {
                            Text("Why does it take so long?")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            Button(action: { showDelayInfo = true }) {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    
                    
                    // Total Cost
//                    let total = convertPriceToInt(robotPrice) + convertPriceToInt(shippingCost)
//                    VStack(alignment: .leading, spacing: 16) {
//                        infoRow("Total", value: "$" + "\(total)")
//                    }
//                    .padding(.horizontal, 32)
//                    .padding(.top, 32)
                    

                    // Expedite delivery option
                    VStack(spacing: 16) {
                        Text("Want to reduce the delivery time?")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button(action: { showSponsorshipOptions = true }) {
                            Text("Support Mars Projects")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(sponsorshipSpeedup == nil ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 32)
                        
                        Button(action: {
                            // Proceed without sponsoring
                            Logger.logInfo("User chose to launch without sponsoring")
                            // No change to delivery time
                        }) {
                            Text(sponsorshipSpeedup == nil ? "proceed without sponsoring" : "Checkout")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(sponsorshipSpeedup == nil ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Place Order")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSponsorshipOptions) {
            SponsorshipOptionsView(model: model, onSponsor: { speedup in
                sponsorshipSpeedup = speedup
                newDelivery = calculateNewDelivery(speedup: speedup)
            })
        }
        .alert(isPresented: $showDelayInfo) {
            Alert(
                title: Text("Why the Delay?"),
                message: Text("Delivery to Mars is affected by launch site weather, orbital paths, landing site conditions, and a high number of pending deployments. We appreciate your patience!"),
                dismissButton: .default(Text("Got it"))
            )
        }
    }

    // Helper for info rows
    private func infoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 150, alignment: .leading)
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
        }
    }

    //여기 로직 다시 고쳐야됨.
    // Calculate new delivery date based on speedup
    private func calculateNewDelivery(speedup: Int) -> String {
        //let months = Int(speedup.prefix(1)) ?? 0
        let days = speedup
        let baseDate = "\(bot.estimatedDelivery)"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        if speedup == 0 {
            newDelivery = nil
            sponsorshipSpeedup = nil
        }
        if let date = formatter.date(from: baseDate) {
            if let newDate = Calendar.current.date(byAdding: .day, value: -days, to: date) {
                return formatter.string(from: newDate)
            }
        }
        return estimatedDelivery // Fallback
    }
    
    func convertPriceToInt(_ priceString: String) -> Int? {
        // "$" 제거하고 숫자만 남김
        let cleanString = priceString.replacingOccurrences(of: "$", with: "")
        // Int로 변환
        return Int(cleanString)
    }
}

    
// SponsorshipOptionsView
struct SponsorshipOptionsView: View {
    let model: String
    let onSponsor: (Int) -> Void
    @StateObject private var sponsorList = OrderSponsorList()
    @Environment(\.dismiss) private var dismiss

    private var sponsorships: [Sponsorship] {
        sponsorList.sponsors.map { item in
            Sponsorship(
                name: item.name,
                price: item.price,
                deliveryBenefit: item.deliveryBenefit,
                speedUpDay: item.speedUpDay,
                dividend: item.dividend,
                id: item.id
            )
        }
    }
    
    var body: some View {
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 16) {
//                            Text("Support Mars Projects")
//                                .font(.system(size: 28, weight: .bold))
//                                .foregroundColor(.white)
//                                .padding(.top, 32)
                            Text("Sponsor these projects to speed up your delivery and earn dividends.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            if sponsorships.isEmpty {
                                Text("No sponsorship options available")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                                    .padding(.top, 16)
                            } else {
                                ForEach(sponsorships, id: \.id) { option in
                                    SponsorshipCard(
                                        title: option.name,
                                        cost: option.price,
                                        speedup: option.deliveryBenefit,
                                        dividend: option.dividend,
                                        imageName: option.id,
                                        onSponsor: {
                                            onSponsor(option.speedUpDay)
                                            dismiss()
                                        }
                                    )
                                    
                                }
                            }
                        }
                        .padding(.bottom, 32)
                        Button(action: {
                            // Proceed without sponsoring
                            Logger.logInfo("User chose to launch without sponsoring")
                            onSponsor(0)
                            dismiss()
                        }) {
                        Text("proceed without sponsoring")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .underline()
                        }
                    }
                }
                .preferredColorScheme(.dark)
                .navigationTitle("Support Mars Project")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }
                }
                .onAppear {
                    print("Sponsors count: \(sponsorList.sponsors.count)")
                }
            }
        }
    }

    // SponsorshipCard
    struct SponsorshipCard: View {
        let title: String
        let cost: String
        let speedup: String
        let dividend: String
        let imageName: String
        let onSponsor: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(8)
                    .overlay {
                        if UIImage(named: imageName) == nil {
                            Color.gray.opacity(0.5)
                            Text("Image not found")
                                .foregroundColor(.white)
                        }
                    }
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text("Cost: \(cost)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("Speed Up: \(speedup)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("Dividend: \(dividend)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Button(action: onSponsor) {
                    Text("Add to Purchase")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 32)
        }
    }

    // SponsorListView
    struct SponsorListView: View {
        @StateObject private var sponsorList = OrderSponsorList()

        var body: some View {
            List(sponsorList.sponsors) { sponsor in
                VStack(alignment: .leading) {
                    Text(sponsor.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Price: \(sponsor.price)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Delivery: \(sponsor.deliveryBenefit)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Dividend: \(sponsor.dividend)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .preferredColorScheme(.dark)
            .background(Color.black.ignoresSafeArea())
        }
    }

    // Preview
#Preview {
    BuyBotOrderView(model: "Gen6")
}
