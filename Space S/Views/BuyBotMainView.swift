//
//
//  BuyBotMainView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//

import SwiftUI
import SwiftData

struct BuyBotMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User
    @Binding var path: [Route]
    @State private var selectedModel: String = "Gen6" // 기본 선택: Gen6
    @StateObject private var bot1: Bot
    @StateObject private var bot2: Bot
    
    init(path: Binding<[Route]>, currentUser: User) {
        self._path = path
        self.user = currentUser
        // 기본 Bot 인스턴스 생성  (Gen6를 기본값으로 사용)
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
        .onAppear {
            Logger.logInfo("BuyBotMainView appeared")
        }
    }
    
    // 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 16) {
            //Image(selectedModel == "Gen6" ? "\(bot1.model)" : "\(bot2.model)")
            Image("\(selectedBot.model)")
                .resizable()
                .scaledToFill()
                //.frame(height: .infinity)
                .frame(maxWidth: .infinity)
                .clipped()
            
            Text("Optimus \(selectedBot.model): Mars' AI Citizen")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text(selectedBot.model == "\(bot1.model)" ? "Send an advanced AI citizen to lead Mars' autonomous cities and secure your survival on Earth." : "Deploy a reliable AI resident to support Mars' growing civilization and ensure your war exemption.")
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
    
    private var selectedBot: Bot {
        selectedModel == bot1.model ? bot1 : bot2
    }
    
    // 기능 비교 섹션
    private var featureComparisonSection: some View {
        VStack(spacing: 24) {
            // Gen6 기능
            if selectedModel == "\(bot1.model)" {
                FeatureCard(
                    title: "Quantum AI Neuralnet",
                    description: "\(bot1.model)'s AI outpaces human neurons for precise control and agility, excelling in sports like football and other dynamic, high-precision tasks.",
                    icon: "brain"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Advanced Dexterity",
                    description: "Powered by \(bot1.physical.hand_dof) DOF hands, \(bot1.model) delivers surgical precision, artistic creativity, and masterful performance on string instruments.",
                    icon: "hand.raised"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Extended Operation",
                    description: "\(bot1.hardware.batteryLife) of autonomy with ultra-fast charging — optimized for vibrant city life on Mars.",
                    icon: "battery.100"
                ).padding(.horizontal, 32)
            }
            // Gen5 기능
            else {
                FeatureCard(
                    title: "Reliable AI Core",
                    description: "\(bot2.model)'s reliable AI core ensures stable actuator control for smooth, fluid dance moves.",
                    icon: "brain"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Functional Dexterity",
                    description: "With \(bot2.physical.hand_dof) dof in their hands, \(bot2.model) robots can master sewing and knitting with reliable skill. ",
                    icon: "hand.raised"
                ).padding(.horizontal, 32)
                FeatureCard(
                    title: "Standard Operation",
                    description: "\(bot2.hardware.batteryLife) of autonomy and fast charging make it ideal for everyday life in Martian environments.",
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
            
//            SpecCard(
//                title: "Height",
//                description: "\(selectedBot.physical.height)"
//            ).padding(.horizontal, 32)
            VStack {
                // Gen6 기능
                if selectedModel == "\(bot1.model)" {
                    SpecCard(
                        title: "Height",
                        description: "\(bot1.physical.height)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Weight",
                        description: "\(bot1.physical.weight)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Payload",
                        description: "\(bot1.physical.payload)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Hand DOF",
                        description: "\(bot1.physical.hand_dof)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Operation Duration",
                        description: "\(bot1.hardware.batteryLife)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "AI Processing",
                        description: "\(bot1.hardware.cpu)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Price",
                        description: "$\(bot2.price)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                }
                // Gen5 기능
                else {
                    SpecCard(
                        title: "Height",
                        description: "\(bot2.physical.height)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Weight",
                        description: "\(bot2.physical.weight)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Payload",
                        description: "\(bot2.physical.payload)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Hand DOF",
                        description: "\(bot2.physical.hand_dof)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Operation Duration",
                        description: "\(bot2.hardware.batteryLife)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "AI Processing",
                        description: "\(bot2.hardware.cpu)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                    SpecCard(
                        title: "Price",
                        description: "$\(bot2.price)"
                    ).padding(.horizontal, 32).padding(.top, 16)
                }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 32)

        }
    
    }
    
    
    // 주문 버튼 섹션
    private var orderButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Logger.logInfo("Order Now button tapped for Optimus \(selectedBot.model)")
                path.append(.order(user: self.user, model: selectedModel)) // OrderView로 이동
            }) {
                Text("Send to Mars")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: 400)
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
                //Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // 사양 행 뷰

    private struct SpecCard: View {
        let title: String
        let description: String

        var body: some View {
            VStack {

                HStack(spacing: 16) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 120, alignment: .leading)
                    Text(description)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth : 400)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.8))
        }
    }

//
//#Preview {
//    BuyBotMainView(path: .constant([Route.buyBot]))
//}
