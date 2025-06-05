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
    
    // CPM 서비스를 위한 인스턴스
    private let cpmService = CPMService()
    // 계산된 예상 도착 날짜를 저장할 상태 변수
    @State private var estimatedArrivalDateString: String = "계산 중..."
    
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
            // 뷰가 나타날 때 예상 도착 시간 계산
            calculateAndUpdateEstimatedArrival()
        }
        .onChange(of: selectedModel) { _, _ in
            // 모델이 변경될 때마다 예상 도착 시간 다시 계산
            calculateAndUpdateEstimatedArrival()
        }
        .onChange(of: user.waitList) { _, _ in
            // 대기 목록이 변경될 때마다 예상 도착 시간 다시 계산 (필요한 경우)
            calculateAndUpdateEstimatedArrival()
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
                        description: "$\(bot1.price)"
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
    
    
    // 주문 버튼 섹션 (예상 도착 시간 표시 업데이트)
    private var orderButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Logger.logInfo("Order Now button tapped for Optimus \(selectedBot.model)")
                // 주문 완료 시점에 User 객체의 estimatedArrivalAtMarsDate 업데이트
                updateUserEstimatedArrivalDate()
                path.append(.order(user: self.user, model: selectedModel))
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
            
            // 계산된 예상 도착 시간 표시
            Text("Expected Mars arrival: \(estimatedArrivalDateString)")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.bottom, 32)
    }
    
    // 예상 도착 시간을 계산하고 UI를 업데이트하는 함수
    private func calculateAndUpdateEstimatedArrival() {
        // 1. 활동 정의 (사용자 데이터 및 선택된 모델 기반)
        // user.waitList가 0이면 생산 대기 시간도 0이 되도록 처리
        let productionWaitDuration = user.waitList > 0 ? max(1, Int(round(Double(user.waitList) / 5000.0))) : 0
        
        let activities: [CPMActivity] = [
            // "A"라는 시작점이 없으므로, 첫 활동의 predecessors는 비워둡니다.
            CPMActivity(id: "B", name: "로봇 생산 대기", duration: productionWaitDuration, predecessors: []),
            CPMActivity(id: "C", name: "로봇 생산", duration: 2, predecessors: ["B"]),
            CPMActivity(id: "D", name: "로봇 캘리브레이션 (지구)", duration: 1, predecessors: ["C"]),
            CPMActivity(id: "E", name: "발사장 운송", duration: 3, predecessors: ["D"]),
            CPMActivity(id: "F", name: "발사 대기", duration: 20, predecessors: ["E"]),
            CPMActivity(id: "G", name: "발사", duration: 1, predecessors: ["F"]),
            CPMActivity(id: "H", name: "우주 비행", duration: 203, predecessors: ["G"]),
            CPMActivity(id: "I", name: "화성 착륙", duration: 1, predecessors: ["H"]),
            // ID "I" 중복 수정 및 선행 작업 수정
            CPMActivity(id: "J", name: "로봇 캘리브레이션 (화성)", duration: 1, predecessors: ["I"])
        ]
        
        // 2. CPM 계산 실행
        let calculatedActivities = cpmService.calculateCPM(activities: activities)
        
        // 3. "화성 착륙" 활동의 EF(Early Finish) 찾기
        //    여기서는 마지막 활동인 "로봇 캘리브레이션 (화성)"의 EF를 기준으로 합니다.
        //    또는 특정 ID ("I" - 화성 착륙)의 EF를 사용할 수도 있습니다.
        if let marsLandingCalibrationActivity = calculatedActivities.first(where: { $0.id == "J" }) {
            let totalDays = marsLandingCalibrationActivity.earlyFinish
            
            // 현재 날짜에 총 소요 일수를 더하여 예상 도착 날짜 계산
            let calendar = Calendar.current
            if let arrivalDate = calendar.date(byAdding: .day, value: totalDays, to: Date()) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/M/d"
                estimatedArrivalDateString = dateFormatter.string(from: arrivalDate)
            } else {
                estimatedArrivalDateString = "날짜 계산 오류"
            }
        } else if let marsLandingActivity = calculatedActivities.first(where: { $0.id == "I" }) { // J가 없다면 I 기준
            let totalDays = marsLandingActivity.earlyFinish
            let calendar = Calendar.current
            if let arrivalDate = calendar.date(byAdding: .day, value: totalDays, to: Date()) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/M/d"
                estimatedArrivalDateString = dateFormatter.string(from: arrivalDate)
            } else {
                estimatedArrivalDateString = "날짜 계산 오류"
            }
        }
        else {
            estimatedArrivalDateString = "계산 불가"
            // CPM 계산 실패 또는 "J" 활동을 찾을 수 없는 경우
            if calculatedActivities.isEmpty && !activities.isEmpty {
                Logger.logError("CPM calculation failed, possibly due to a cycle or graph error.")
            } else {
                Logger.logError("Could not find Mars landing calibration activity (ID: J) in CPM results.")
            }
        }
    }
    // User 객체의 estimatedArrivalAtMarsDate를 업데이트하는 함수
    private func updateUserEstimatedArrivalDate() {
        // calculateAndUpdateEstimatedArrival() 함수와 유사하게 CPM을 다시 계산하거나,
        // 이미 계산된 estimatedArrivalDateString을 Date 객체로 변환하여 저장합니다.
        // 여기서는 간단히 현재 계산된 문자열을 기반으로 Date를 다시 만듭니다.
        
        // 주의: 이 방식은 estimatedArrivalDateString이 항상 유효한 날짜 문자열일 때만 정확합니다.
        // 더 견고한 방법은 calculateAndUpdateEstimatedArrival 내부에서 Date 객체를 저장해두고 사용하는 것입니다.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/M/d"
        if let date = dateFormatter.date(from: estimatedArrivalDateString) {
            user.estimatedArrivalAtMarsDate = date
            Logger.logInfo("User's estimatedArrivalAtMarsDate updated to: \(date)")
        } else {
            // 만약 estimatedArrivalDateString이 "계산 중...", "날짜 계산 오류", "계산 불가" 등이라면
            // user.estimatedArrivalAtMarsDate를 nil로 설정하거나 이전 값을 유지할 수 있습니다.
            // 여기서는 nil로 설정하지 않고, 오류 로그만 남깁니다.
            Logger.logError("Could not parse estimatedArrivalDateString ('\(estimatedArrivalDateString)') to Date for User object.")
        }
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
//
//// 사양 행 뷰 (SpecCard 내부 패딩 조정)
//private struct SpecCard: View {
//    let title: String
//    let description: String
//    
//    var body: some View {
//        HStack(spacing: 16) { // VStack 제거하고 HStack으로 변경
//            Text(title)
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.white)
//                .frame(width: 120, alignment: .leading) // 너비 고정 및 정렬
//            Text(description)
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//            Spacer() // 오른쪽으로 밀착
//        }
//        .padding(.horizontal) // 좌우 패딩 추가
//        .padding(.vertical, 8) // 상하 패딩 추가 (줄 간격 역할)
//        // .frame(maxWidth: .infinity, alignment: .leading) // HStack에 이미 적용됨
//        // .background(Color.black.opacity(0.8)) // 부모 VStack에서 배경 설정
//    }
//}


//
//#Preview {
//    BuyBotMainView(path: .constant([Route.buyBot]))
//}
