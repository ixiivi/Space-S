//
//
//  BuyBotMainView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//


import SwiftUI

struct BuyBotMainView: View {
    @Binding var path: [Route] // LoginView의 path 공유
    @State private var selectedModel: String = "Gen6" // 기본 선택: Gen6

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // 어두운 배경

            ScrollView {
                VStack(spacing: 0) {
                    // 헤더 섹션
                    headerSection

                    // 모델 선택 섹션
                    modelSelectionSection

                    // 기능 비교 섹션
                    featureComparisonSection

                    // 사양 테이블 섹션
                    specsTableSection

                    // 주문 버튼 섹션
                    orderButtonSection
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Build Mars’ AI Civilization")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Logger.logInfo("Menu button tapped")
                    // 메뉴 액션 (예: 설정, 로그아웃)
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            Logger.logInfo("BuyBotMainView appeared")
        }
    }

    // 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(selectedModel == "Gen6" ? "optimus_gen6" : "optimus_gen5")
                .resizable()
                .scaledToFill()
                .frame(height: 400)
                .clipped()

            Text("Optimus \(selectedModel): Mars’ AI Citizen")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            Text(selectedModel == "Gen6" ? "Send an advanced AI citizen to lead Mars’ autonomous cities and secure your survival on Earth." : "Deploy a reliable AI resident to support Mars’ growing civilization and ensure your war exemption.")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // 모델 선택 섹션
    private var modelSelectionSection: some View {
        VStack(spacing: 16) {
            Text("Select Your AI Citizen")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 32)

            Picker("Model", selection: $selectedModel) {
                Text("Gen6").tag("Gen6")
                Text("Gen5").tag("Gen5")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)
            .onChange(of: selectedModel) { oldValue, newValue in
                Logger.logInfo("Model selected: \(newValue)")
            }
        }
    }

    // 기능 비교 섹션
    private var featureComparisonSection: some View {
        VStack(spacing: 24) {
            Text("Why Deploy Optimus \(selectedModel)?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 32)

            // Gen6 기능
            if selectedModel == "Gen6" {
                FeatureCard(
                    title: "Quantum AI Consciousness",
                    description: "Self-evolving AI for leading autonomous city operations, managing infrastructure, and coordinating AI communities on Mars.",
                    icon: "brain"
                )
                FeatureCard(
                    title: "Advanced Dexterity",
                    description: "22 DOF hands for precise tasks like assembling habitats and maintaining recharge stations in Martian cities.",
                    icon: "hand.raised"
                )
                FeatureCard(
                    title: "Extended Operation",
                    description: "72-hour autonomy with solar charging, optimized for continuous city management in Mars’ harsh environment.",
                    icon: "battery.100"
                )
            }
            // Gen5 기능
            else {
                FeatureCard(
                    title: "Reliable AI Core",
                    description: "Stable AI for supporting city operations, maintaining infrastructure, and assisting AI communities on Mars.",
                    icon: "brain"
                )
                FeatureCard(
                    title: "Functional Dexterity",
                    description: "11 DOF hands for essential tasks like habitat maintenance and equipment setup in Martian cities.",
                    icon: "hand.raised"
                )
                FeatureCard(
                    title: "Standard Operation",
                    description: "24-hour autonomy with fast charging, suitable for ongoing support in Martian urban environments.",
                    icon: "battery.100"
                )
            }
        }
        .padding(.horizontal, 32)
    }

    // 사양 테이블 섹션
    private var specsTableSection: some View {
        VStack(spacing: 16) {
            Text("Citizen Specifications")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 32)

            VStack(alignment: .leading, spacing: 12) {
                specRow("Height", gen5: "5 ft 8 in (173 cm)", gen6: "5 ft 10 in (178 cm)")
                specRow("Weight", gen5: "125 lb (57 kg)", gen6: "110 lb (50 kg)")
                specRow("Payload", gen5: "45 lb (20 kg)", gen6: "60 lb (27 kg)")
                specRow("Hand DOF", gen5: "11", gen6: "22")
                specRow("Operation Duration", gen5: "24 hours", gen6: "72 hours")
                specRow("AI Processing", gen5: "Standard Neural Net", gen6: "Quantum Neural Core")
                specRow("City Roles", gen5: "Support, Maintenance", gen6: "Leadership, Autonomy")
                specRow("Deployment Cost", gen5: "$30,000", gen6: "$50,000")
            }
            .padding(.horizontal, 32)
        }
    }

    // 주문 버튼 섹션
    private var orderButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Logger.logInfo("Order Now button tapped for Optimus \(selectedModel)")
                path.append(.order(model: selectedModel)) // OrderView로 이동
            }) {
                Text("Send to Mars")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedModel == "Gen6" ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)

            Text("Expected Mars arrival: \(selectedModel == "Gen6" ? "Q3 2032" : "Q1 2036")")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.bottom, 32)
    }

    // 기능 카드 뷰
    private struct FeatureCard: View {
        let title: String
        let description: String
        let icon: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // 사양 행 뷰
    private func specRow(_ title: String, gen5: String, gen6: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 120, alignment: .leading)
            Text(selectedModel == "Gen6" ? gen6 : gen5)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

#Preview {
    BuyBotMainView(path: .constant([Route.buyBot]))
}
