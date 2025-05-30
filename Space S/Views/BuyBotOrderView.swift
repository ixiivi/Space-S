//
//  BuyBotOrderView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//

import SwiftUI

public struct BuyBotOrderView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var path: [Route]
    @Bindable var currentUser: User
    
    public let model: String
    @State private var showDelayInfo = false // For delay explanation popup
    @State private var showSponsorshipOptions = false // For sponsorship sheet
    @State private var sponsorshipSpeedup: Int? = nil // Tracks selected sponsorship speedup
    @State private var sponsorshipPrice: Int? = nil
    @State private var newDelivery: String? = nil // New delivery date after sponsorship
    @State private var totalPrice: Int? = nil
    @StateObject private var bot: Bot
    @StateObject private var sponsorList = OrderSponsorList()
    
    // Robot prices and shipping details
    private var robotPrice: Int { bot.price }
    private var shippingCost: Int { bot.shippingCost }
    private var estimatedDelivery: String { bot.estimatedDelivery }
    
    init(path: Binding<[Route]>, currentUser: User, model: String) {
        self._path = path
        self._currentUser = Bindable(wrappedValue: currentUser)
        self.model = model
        // 기본 Bot  인스턴스 생성 (Gen6를 폴백으로 사용)
        let defaultBot = Bot(modelName: "Gen6")!
        _bot = StateObject(wrappedValue: Bot(modelName: model) ?? defaultBot)
    }
    

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
                            //.frame(height: .infinity)
                            .frame(maxWidth: .infinity)
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
                    VStack(alignment:.center, spacing: 0){
                        // Robot price and details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Order Summary")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 400, alignment: .leading)
                            infoRow("Model", value: "Optimus \(model)")
                            infoRow("Price", value: "$\(robotPrice)")
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        .frame(maxWidth: 400, alignment: .leading)
                        
                        
                        // Shipping information
                        VStack(alignment: .leading, spacing: 16) {
                            infoRow("Shipping Cost", value: "$\(shippingCost)")
                            if sponsorshipSpeedup == nil {
                                infoRow("Estimated Delivery", value: estimatedDelivery)
                                
                            } else {
                                //infoRow("Estimated Delivery", value: estimatedDelivery)
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
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(newDelivery ?? "error")")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                    }
                                }
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
                        .frame(maxWidth: 400, alignment: .leading)
                        
                        //Total Cost
                        VStack(alignment: .leading, spacing: 16) {
                            HStack{
                                infoRow(
                                    "Total", value: "$\(totalPrice ?? 0)"
                                )
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .onAppear {
                                totalPrice = calculateTotalPrice()
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        .frame(maxWidth: 400, alignment: .leading)
                        
                    
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    

                    // Expedite delivery option
                    VStack(spacing: 16) {
                        Text("Want to reduce the delivery time?")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button(action: { showSponsorshipOptions = true }) {
                            Text("Support Mars Projects")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth:400)
                                .padding()
                                .background(sponsorshipSpeedup == nil ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 32)
                        
                        Button(action: {
                            completeOrderAndNavigate()
                        }) {
                            Text(sponsorshipSpeedup == nil ? "proceed without sponsoring" : "Checkout")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: 400)
                                .padding()
                                .background(sponsorshipSpeedup == nil ? Color.black : Color.blue)
                                .foregroundColor(sponsorshipSpeedup == nil ? Color.gray : Color.white)
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
            SponsorshipOptionsView(model: model, onSponsor: { speedup , price in
                sponsorshipSpeedup = speedup
                sponsorshipPrice = price
                newDelivery = calculateNewDelivery(speedup: speedup)
                totalPrice = calculateTotalPrice(price: price)
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


    private func completeOrderAndNavigate() {
        // 1. currentUser에 선택된 봇 모델명 저장
        currentUser.selectedBot = self.model
        Logger.logInfo("Order Completion: Bot model '\(self.model)' set for user '\(currentUser.name)'.")

        // 2. 스폰서십 정보 저장 (선택적)
        if let spPrice = sponsorshipPrice, spPrice > 0, let spSpeedup = sponsorshipSpeedup {
            // 예시: 스폰서 이름을 저장하거나, 스폰서십 적용 여부 플래그를 설정
            // User 모델에 'sponsorDetails: String?' 같은 필드가 있다고 가정
            // currentUser.sponsor = "Sponsored: \(spSpeedup) days faster for $\(spPrice)"
            // 또는 현재 User 모델의 sponsor: String? 필드 활용
            let selectedSponsor = sponsorList.sponsors.first { $0.price == spPrice && $0.speedUpDay == spSpeedup }
            currentUser.sponsor = selectedSponsor?.name ?? "Custom Sponsorship (\(spPrice))" // 스폰서 이름 저장
            Logger.logInfo("Order Completion: Sponsorship '\(currentUser.sponsor ?? "N/A")' applied.")
        } else {
            currentUser.sponsor = nil // 스폰서십 없음
            Logger.logInfo("Order Completion: No sponsorship applied.")
        }
        
        // 3. SwiftData에 변경사항 저장
        do {
            try modelContext.save()
            Logger.logInfo("Order Completion: User data saved successfully for user '\(currentUser.name)'.")
        } catch {
            Logger.logError("Order Completion: Failed to save user data. Error: \(error.localizedDescription)")
            // 사용자에게 저장 실패 알림을 표시할 수 있습니다. (선택적)
            // 이 단계에서 저장 실패 시 주문 완료 화면으로 넘어가지 않도록 처리할 수도 있습니다.
        }

        // 4. OrderCompleteView로 네비게이션
        path.append(.orderComplete(user: self.currentUser))
    }
    
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
    private func calculateTotalPrice(price: Int = 0) -> Int {
        let SponsorPrice = price
        return bot.price + bot.shippingCost + SponsorPrice
    }

}

    
// SponsorshipOptionsView
struct SponsorshipOptionsView: View {
    let model: String
    let onSponsor: (Int, Int) -> Void
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
                                        onSponsor(option.speedUpDay, option.price)
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
                        onSponsor(0, 0)
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
        let cost: Int
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
                Text("Cost: $\(cost)")
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

//#Preview {
//    BuyBotOrderView(model: "Gen6")
//}
