//////
//////  BuyBotOrderView.swift
//////  Space S
//////
//////  Created by 김재현 on 5/10/25.
//////
//
//
//
//import SwiftUI
//
//public struct BuyBotOrderView: View {
//    public let model: String
//    @State private var showDelayInfo = false // For delay explanation popup
//    @State private var showSponsorshipOptions = false // For sponsorship sheet
//
//    // Robot prices and shipping details
//    private var robotPrice: String {
//        model == "Gen6" ? "$50,000" : "$30,000"
//    }
//    private var shippingCost: String = "$10,000"
//    private var estimatedDelivery: String {
//        model == "Gen6" ? "Q3 2026" : "Q1 2026"
//    }
//
//    public init(model: String) {
//        self.model = model
//    }
//
//    public var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea() // Dark background like BuyBotMainView
//
//            ScrollView {
//                VStack(spacing: 0) {
//                    // Header with robot image and title
//                    VStack(spacing: 16) {
//                        Image(model == "Gen6" ? "optimus_gen6" : "optimus_gen5")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(height: 300)
//                            .clipped()
//                        Text("Optimus \(model) Order")
//                            .font(.system(size: 36, weight: .bold))
//                            .foregroundColor(.white)
//                        Text("Your AI citizen is ready for Mars deployment.")
//                            .font(.system(size: 18))
//                            .foregroundColor(.gray)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 32)
//                    }
//
//                    // Robot price and details
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Robot Details")
//                            .font(.system(size: 24, weight: .bold))
//                            .foregroundColor(.white)
//                        infoRow("Model", value: "Optimus \(model)")
//                        infoRow("Price", value: robotPrice)
//                    }
//                    .padding(.horizontal, 32)
//                    .padding(.top, 32)
//
//                    // Shipping information
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Shipping Information")
//                            .font(.system(size: 24, weight: .bold))
//                            .foregroundColor(.white)
//                        infoRow("Shipping Cost", value: shippingCost)
//                        infoRow("Estimated Delivery", value: estimatedDelivery)
//                        HStack {
//                            Text("Why does it take so long?")
//                                .font(.system(size: 16))
//                                .foregroundColor(.gray)
//                            Button(action: { showDelayInfo = true }) {
//                                Image(systemName: "questionmark.circle")
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 32)
//                    .padding(.top, 32)
//
//                    // Expedite delivery option
//                    VStack(spacing: 16) {
//                        Text("Want to reduce the delivery time?")
//                            .font(.system(size: 18, weight: .medium))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                        Button(action: { showSponsorshipOptions = true }) {
//                            Text("Support Mars Projects")
//                                .font(.system(size: 16, weight: .bold))
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .clipShape(Capsule())
//                        }
//                        .padding(.horizontal, 32)
//                    }
//                    .padding(.top, 32)
//                    .padding(.bottom, 32)
//                }
//            }
//        }
//        .preferredColorScheme(.dark)
//        .navigationTitle("Place Order")
//        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $showSponsorshipOptions) {
//            SponsorshipOptionsView(model: model)
//        }
//        .alert(isPresented: $showDelayInfo) {
//            Alert(
//                title: Text("Why the Delay?"),
//                message: Text("Delivery to Mars is affected by launch site weather, orbital paths, landing site conditions, and a high number of pending deployments. We appreciate your patience!"),
//                dismissButton: .default(Text("Got it"))
//            )
//        }
//    }
//
//    // Helper for info rows
//    private func infoRow(_ title: String, value: String) -> some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.white)
//                .frame(width: 150, alignment: .leading)
//            Text(value)
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//            Spacer()
//        }
//    }
//}
//
//// Sponsorship options view
//struct SponsorshipOptionsView: View {
//    let model: String
//    @Environment(\.dismiss) private var dismiss
//
//    private let sponsorships = [
//        ("Robot Charging Station", "$5,000", "1 month faster", "5% dividend"),
//        ("Robot School", "$10,000", "2 months faster", "10% dividend"),
//        ("Robot Park", "$15,000", "3 months faster", "15% dividend"),
//        ("Mars Mining Development", "$20,000", "4 months faster", "20% dividend"),
//        ("Orbital Relay Station", "$25,000", "5 months faster", "25% dividend")
//    ]
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.black.ignoresSafeArea()
//                ScrollView {
//                    VStack(spacing: 16) {
//                        Text("Support Mars Projects")
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundColor(.white)
//                            .padding(.top, 32)
//                        Text("Sponsor these projects to speed up your delivery and earn dividends.")
//                            .font(.system(size: 16))
//                            .foregroundColor(.gray)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 32)
//                        ForEach(sponsorships, id: \.0) { option in
//                            SponsorshipCard(
//                                title: option.0,
//                                cost: option.1,
//                                speedup: option.2,
//                                dividend: option.3
//                            )
//                        }
//                    }
//                    .padding(.bottom, 32)
//                }
//            }
//            .preferredColorScheme(.dark)
//            .navigationTitle("Expedite Delivery")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// Sponsorship card component
//struct SponsorshipCard: View {
//    let title: String
//    let cost: String
//    let speedup: String
//    let dividend: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.system(size: 18, weight: .bold))
//                .foregroundColor(.white)
//            Text("Cost: \(cost)")
//                .font(.system(size: 14))
//                .foregroundColor(.gray)
//            Text("Speedup: \(speedup)")
//                .font(.system(size: 14))
//                .foregroundColor(.gray)
//            Text("Dividend: \(dividend)")
//                .font(.system(size: 14))
//                .foregroundColor(.gray)
//            Button(action: {
//                // Placeholder for payment logic
//                print("Sponsored \(title) for \(cost)")
//            }) {
//                Text("Sponsor Now")
//                    .font(.system(size: 14, weight: .bold))
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 8)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .clipShape(Capsule())
//            }
//        }
//        .padding()
//        .background(Color.black.opacity(0.8))
//        .cornerRadius(12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.white.opacity(0.2), lineWidth: 1)
//        )
//        .padding(.horizontal, 32)
//    }
//}
//
//#Preview {
//    BuyBotOrderView(model: "Gen6")
//}

import SwiftUI

public struct BuyBotOrderView: View {
    public let model: String
    @State private var showDelayInfo = false // For delay explanation popup
    @State private var showSponsorshipOptions = false // For sponsorship sheet
    @State private var sponsorshipSpeedup: String? = nil // Tracks selected sponsorship speedup
    @State private var newDelivery: String? = nil // New delivery date after sponsorship

    // Robot prices and shipping details
    private var robotPrice: String {
        model == "Gen6" ? "$50,000" : "$30,000"
    }
    private var shippingCost: String = "$10,000"
    private var estimatedDelivery: String {
        model == "Gen6" ? "Q3 2032" : "Q1 2036"
    }

    public init(model: String) {
        self.model = model
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Dark background like BuyBotMainView

            ScrollView {
                VStack(spacing: 0) {
                    // Header with robot image and title
                    VStack(spacing: 16) {
                        Image(model == "Gen6" ? "optimus_gen6" : "optimus_gen5")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                        Text("Optimus \(model) Order")
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
                        Text("Robot Details")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        infoRow("Model", value: "Optimus \(model)")
                        infoRow("Price", value: robotPrice)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)

                    // Shipping information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Shipping Information")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        infoRow("Shipping Cost", value: shippingCost)
                        if let newDelivery = newDelivery, let sponsorshipSpeedup = sponsorshipSpeedup {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Estimated Delivery")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 150, alignment: .leading)
                                Text(estimatedDelivery)
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .strikethrough(true, color: .red)
                                Text("\(newDelivery) (\(sponsorshipSpeedup))")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
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
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 32)
                        Button(action: {
                            // Proceed without sponsoring
                            Logger.logInfo("User chose to launch without sponsoring")
                            // No change to delivery time
                        }) {
                            Text("proceed without sponsoring")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .underline()
                        }
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

    // Calculate new delivery date based on speedup
    private func calculateNewDelivery(speedup: String) -> String {
        let months = Int(speedup.prefix(1)) ?? 0
        let baseDate = model == "Gen6" ? "July 2026" : "January 2026"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        if let date = formatter.date(from: baseDate) {
            if let newDate = Calendar.current.date(byAdding: .month, value: -months, to: date) {
                return formatter.string(from: newDate)
            }
        }
        return estimatedDelivery // Fallback
    }
}

// Sponsorship options view
struct SponsorshipOptionsView: View {
    let model: String
    let onSponsor: (String) -> Void // Callback for sponsorship selection
    @Environment(\.dismiss) private var dismiss

    private let sponsorships = [
        ("Robot Charging Station", "$5,000", "10 days faster", "0-1% dividend", "charging_station"),
        ("Robot School", "$10,000", "20 days faster", "0-1.12% dividend", "robot_school"),
        ("Robot Park", "$15,000", "1 month faster", "1.9% dividend", "robot_park"),
        ("Mars Mining Development", "$87,000", "6 months faster", "2.9% dividend", "mars_mining"),
        ("Orbital Relay Station", "$99,000", "6 months faster", "3.1% dividend", "orbital_relay")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Support Mars Projects")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 32)
                        Text("Sponsor these projects to speed up your delivery and earn dividends.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        ForEach(sponsorships, id: \.0) { option in
                            SponsorshipCard(
                                title: option.0,
                                cost: option.1,
                                speedup: option.2,
                                dividend: option.3,
                                imageName: option.4,
                                onSponsor: {
                                    onSponsor(option.2)
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Expedite Delivery")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// Sponsorship card component
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
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text("Cost: \(cost)")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text("Speedup: \(speedup)")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text("Dividend: \(dividend)")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Button(action: onSponsor) {
                Text("Sponsor Now")
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

#Preview {
    BuyBotOrderView(model: "Gen6")
}
