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
    @StateObject private var bot1: Bot
    @StateObject private var bot2: Bot
    
    init(path: Binding<[Route]>) {
        self._path = path
        
        // 기본 Bot 인스턴스 생성 (Gen6를 기본값으로 사용)
        let defaultBot: Bot
        if let bot = Bot(modelName: "Gen6") {
            defaultBot = bot
        } else {
            // Gen6도 실패하면 기본값으로 초기화
            defaultBot = Bot(modelName: "Gen6") ?? Bot(modelName: "Gen5") ?? {
                let bot = Bot(modelName: "Gen5")!
                Logger.logError("Using Gen5 as fallback bot")
                return bot
            }()
        }
        
        // Gen6와 Gen5 Bot 초기화
        _bot1 = StateObject(wrappedValue: Bot(modelName: "Gen6") ?? defaultBot)
        _bot2 = StateObject(wrappedValue: Bot(modelName: "Gen5") ?? defaultBot)
        
        //Logger.logInfo("BuyBotMainView initialized with Gen6: \(_bot1.wrappedValue.model), Gen5: \(_bot2.wrappedValue.model)")
    }

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
        .navigationTitle("Build Mars' AI Civilization")
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
            Image(selectedModel == "Gen6" ? "\(bot1.model)" : "\(bot2.model)")
                .resizable()
                .scaledToFill()
                .frame(height: 400)
                .clipped()

            Text("Optimus \(selectedModel): Mars' AI Citizen")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            Text(selectedModel == "\(bot1.model)" ? "Send an advanced AI citizen to lead Mars' autonomous cities and secure your survival on Earth." : "Deploy a reliable AI resident to support Mars' growing civilization and ensure your war exemption.")
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
                Text("\(bot1.model)").tag("\(bot1.model)")
                Text("\(bot2.model)").tag("\(bot2.model)")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            .onChange(of: selectedModel) { oldValue, newValue in
                Logger.logInfo("Model selected: \(newValue)")
            }
        }
    }

    // 기능 비교 섹션
    private var featureComparisonSection: some View {
        VStack(spacing: 24) {

            // Gen6 기능
            if selectedModel == "\(bot1.model)" {
                FeatureCard(
                    title: "Quantum AI Consciousness",
                    description: "Lead Mars' utopia with innovative social engagement and adaptive empathy.",
                    icon: "brain"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Advanced Dexterity",
                    description: "With \(bot1.physical.hand_dof) dof in their hands, \(bot1.model) robots can craft delicate art, perform complex musical compositions, and lead interactive cultural workshops.",
                    icon: "hand.raised"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Extended Operation",
                    description: "\(bot1.hardware.batteryLife) autonomy with super fast charging, optimized for continuous city life in Mars' harsh environment.",
                    icon: "battery.100"
                ).padding(.horizontal, 32)
            }
            // Gen5 기능
            else {
                FeatureCard(
                    title: "Reliable AI Core",
                    description: "Foster Martian community bonds through consistent and warm interactions.",
                    icon: "brain"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Functional Dexterity",
                    description: "Equipped with \(bot2.physical.hand_dof) dof in their hands, \(bot2.model) robots thrive in Martian social life with expressive interactions by joining games, supporting group tasks, and share warm gestures.",
                    icon: "hand.raised"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Standard Operation",
                    description: "\(bot2.hardware.batteryLife) autonomy with fast charging, suitable for ongoing support in Martian environments.",
                    icon: "battery.100"
                ).padding(.horizontal, 32)
            }
        }
        //.padding(.horizontal, 32)
    }

    // 사양 테이블 섹션
    private var specsTableSection: some View {
        VStack(spacing: 16) {
            Text("Citizen Specifications")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 32)

            VStack(alignment: .leading, spacing: 12) {
                specRow(bot2, title: "Height", bot2: "\(bot2.physical.height)", bot1: "\(bot1.physical.height)")
                specRow(bot2, title:"Weight", bot2: "\(bot2.physical.weight)", bot1: "\(bot1.physical.weight)")
                specRow(bot2, title:"Payload", bot2: "\(bot2.physical.payload)", bot1: "\(bot2.physical.payload)")
                specRow(bot2, title:"Hand DOF", bot2: "\(bot2.physical.hand_dof)", bot1: "\(bot1.physical.hand_dof)")
                specRow(bot2, title:"Operation Duration", bot2: "\(bot2.hardware.batteryLife)", bot1: "\(bot1.hardware.batteryLife)")
                specRow(bot2, title:"AI Processing", bot2: "\(bot2.hardware.cpu)", bot1: "\(bot1.hardware.cpu)")
                specRow(bot2, title:"Deployment Cost", bot2: "\(bot2.price)", bot1: "\(bot1.price)")
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)

            Text("Expected Mars arrival: \(selectedModel == "\(bot2.model)" ? "\(bot2.estimatedDelivery)" : "\(bot1.estimatedDelivery)")")
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
    private func specRow(_ bot:Bot, title: String, bot2: String, bot1: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 120, alignment: .leading)
            Text(selectedModel == "(bot.model)" ? bot1 : bot2)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

#Preview {
    BuyBotMainView(path: .constant([Route.buyBot]))
}
