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
    @State private var showDelayInfo = false
    @State private var showSponsorshipOptions = false
    @State private var selectedSponsorshipSpeedupDays: Int = 0
    @State private var selectedSponsorshipPrice: Int = 0
    @State private var sponsorshipSpeedup: Int? = nil
    @State private var sponsorshipPrice: Int? = nil
    @State private var totalPrice: Int? = nil
    @StateObject private var bot: Bot
    @StateObject private var sponsorList = OrderSponsorList()

    private var robotPrice: Int { bot.price }
    private var shippingCost: Int { bot.shippingCost }

    private let cpmService = CPMService()
    @State private var estimatedArrivalDateString: String = "계산 중..."
    @State private var originalCpmEstimatedArrivalDateString: String? = nil

    init(path: Binding<[Route]>, currentUser: User, model: String) {
        self._path = path
        self._currentUser = Bindable(wrappedValue: currentUser)
        self.model = model
        let defaultBot = Bot(modelName: "Gen6")!
        _bot = StateObject(wrappedValue: Bot(modelName: model) ?? defaultBot)
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        Image(model)
                            .resizable()
                            .scaledToFill()
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

                    VStack(alignment: .center, spacing: 0) {
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

                        VStack(alignment: .leading, spacing: 16) {
                            infoRow("Shipping Cost", value: "$\(shippingCost)")
                            HStack {
                                Text("Estimated Delivery")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 150, alignment: .leading)
                                VStack(alignment: .leading) {
                                    if let original = originalCpmEstimatedArrivalDateString, sponsorshipSpeedup != nil {
                                        Text(original)
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                            .strikethrough(true, color: .red)
                                    }
                                    Text(estimatedArrivalDateString)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                Spacer()
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

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                infoRow("Total", value: "$\(totalPrice ?? 0)")
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
                                calculateAndUpdateEstimatedArrival(applyingSponsorshipSpeedup: 0)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        .frame(maxWidth: 400, alignment: .leading)
                    }

                    VStack(spacing: 16) {
                        Text("Want to reduce the delivery time?")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button(action: { showSponsorshipOptions = true }) {
                            Text("Support Mars Projects")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: 400)
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
            SponsorshipOptionsView(model: model) { speedup, price in
                sponsorshipSpeedup = speedup
                sponsorshipPrice = price
                selectedSponsorshipSpeedupDays = speedup
                selectedSponsorshipPrice = price
                totalPrice = calculateTotalPrice(price: price)
                calculateAndUpdateEstimatedArrival(applyingSponsorshipSpeedup: speedup)
            }
        }
        .alert(isPresented: $showDelayInfo) {
            Alert(
                title: Text("Why the Delay?"),
                message: Text("Delivery to Mars is affected by launch site weather, orbital paths, landing site conditions, and a high number of pending deployments. We appreciate your patience!"),
                dismissButton: .default(Text("Got it"))
            )
        }
    }

    private func calculateTotalPrice(price: Int = 0) -> Int {
        return bot.price + bot.shippingCost + price
    }

    private func completeOrderAndNavigate() {
        currentUser.selectedBot = self.model
        if let spSpeedup = sponsorshipSpeedup, spSpeedup > 0, let spPrice = sponsorshipPrice {
            let selectedSponsor = sponsorList.sponsors.first { $0.price == spPrice && $0.speedUpDay == spSpeedup }
            currentUser.sponsor = selectedSponsor?.name ?? "Custom Sponsorship ($\(spPrice))"
            currentUser.waitList = max(0, currentUser.waitList - (spSpeedup * 5000))
        } else {
            currentUser.sponsor = nil
        }
        updateUserEstimatedArrivalDate()
        

        do {
            try modelContext.save()
            Logger.logInfo("Order Completion: User data saved successfully for user '\(currentUser.name)'.")
            Logger.logInfo("user.isFullySetup : \(currentUser.isFullySetup)")
        } catch {
            Logger.logError("Failed to save user data: \(error.localizedDescription)")
        }
        
    
            // --- 사용자 정보 출력 시작 ---
            print("--- New User Information ---")
            print("ID: \(currentUser.id)")
            print("Name: \(currentUser.name)")
            print("Phone Number: \(currentUser.phoneNumber)")
            print("Selected Bot Model: \(currentUser.selectedBot ?? "N/A")")
            print("Sponsor: \(currentUser.sponsor ?? "N/A")")
            print("Waiting Number: \(currentUser.waitList)")
            //print("Created At: \(newUser.createdAt)")
            //print("Destination: \(newUser.destination ?? "N/A")")
            print("Is Fully Setup: \(currentUser.isFullySetup)")
            print("---------------------------")

        path.append(.orderComplete(user: self.currentUser))
    }

    private func updateUserEstimatedArrivalDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        if let date = formatter.date(from: estimatedArrivalDateString) {
            currentUser.estimatedArrivalAtMarsDate = date
        } else {
            Logger.logError("Could not parse arrival date string: \(estimatedArrivalDateString)")
        }
    }

    private func calculateAndUpdateEstimatedArrival(applyingSponsorshipSpeedup speedupDays: Int) {
        let tempWaitList = max(0, currentUser.waitList - (speedupDays * 5000))
        let productionWaitDuration = tempWaitList > 0 ? max(1, Int(round(Double(tempWaitList) / 5000.0))) : 0

        let activities: [CPMActivity] = [
            CPMActivity(id: "B", name: "로봇 생산 대기", duration: productionWaitDuration, predecessors: []),
            CPMActivity(id: "C", name: "로봇 생산", duration: 2, predecessors: ["B"]),
            CPMActivity(id: "D", name: "로봇 캘리브레이션 (지구)", duration: 1, predecessors: ["C"]),
            CPMActivity(id: "E", name: "발사장 운송", duration: 3, predecessors: ["D"]),
            CPMActivity(id: "F", name: "발사 대기", duration: 20, predecessors: ["E"]),
            CPMActivity(id: "G", name: "발사", duration: 1, predecessors: ["F"]),
            CPMActivity(id: "H", name: "우주 비행", duration: 203, predecessors: ["G"]),
            CPMActivity(id: "I", name: "화성 착륙", duration: 1, predecessors: ["H"]),
            CPMActivity(id: "J", name: "로봇 캘리브레이션 (화성)", duration: 1, predecessors: ["I"])
        ]

        let calculated = cpmService.calculateCPM(activities: activities)
        if let final = calculated.first(where: { $0.id == "J" }) {
            if let arrivalDate = Calendar.current.date(byAdding: .day, value: final.earlyFinish, to: Date()) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/M/d"
                originalCpmEstimatedArrivalDateString = estimatedArrivalDateString
                estimatedArrivalDateString = formatter.string(from: arrivalDate)
            }
        } else {
            estimatedArrivalDateString = "계산 불가"
            Logger.logError("Could not compute CPM result for delivery")
        }
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
