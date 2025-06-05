//
//  EarthSideView.swift
//  Space S
//
//  Created by 김재현 on 5/29/25.
//

import SwiftUI
import SwiftData
import CoreLocation
import WebKit

struct EarthSideView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User
    @Binding var path: [Route]
    @State private var selectedTab: EarthTab = .home
    let logoutAction: () -> Void
    
    enum EarthTab: CaseIterable, Identifiable {
        case home, cpm, changeView, explore, menu
        
        var id: Self { self }
        var iconName: String {
            switch self {
            case .home: "house"
            case .cpm: "calendar"
            case .changeView: "stop"
            case .explore: "magnifyingglass"
            case .menu: "line.horizontal.3"
            }
        }
        var title: String {
            switch self {
            case .home: ""
            case .cpm: ""
            case .changeView: ""
            case .explore: ""
            case .menu: ""
            }
        }
    }
    
    init(path: Binding<[Route]>, user: User, logoutAction: @escaping () -> Void) {
        self._path = path
        self.user = user
        self.logoutAction = logoutAction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            minimalistTopBar()
            
            TabView(selection: $selectedTab) {
                EarthHomeContentView(user: user)
                    .tag(EarthTab.home)
                CPMView(user: user)
                    .tag(EarthTab.cpm)
                //SearchView()
                //    .tag(EarthTab.explore)
                //Text("Search").tag(EarthTab.explore)
                
                EarthSearchView()
                    .tag(EarthTab.explore)
                
                MenuView(user: user, modelContext: modelContext, logoutAction: logoutAction)
                    .tag(EarthTab.menu)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            minimalistTabBar()
        }
        .background(Color.white)
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .environment(\.colorScheme, .light)
    }
    
    private func minimalistTopBar() -> some View {
        HStack {
            Text("Earth")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
    }
    
    private func minimalistTabBar() -> some View {
        HStack {
            ForEach(EarthTab.allCases) { tab in
                Button(action: {
                    if tab == .changeView {
                        path.append(.selectDestination(user: user))
                    } else {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == tab ? Color.accentColor : Color(UIColor.darkGray))
                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == tab ? Color.accentColor : Color(UIColor.darkGray))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(UIColor.systemGray6))
    }
}

struct EarthHomeContentView: View {
    @State private var launchDate: Date? = nil
    @Bindable var user: User
    let totalEarthUsersSendingRobots = 11095
    
    @State private var forecast: ForecastResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let downloader = WeatherDataDownload()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hello, \(user.name)!")
                    .font(.headline)
                    .padding(.horizontal)
                    .foregroundColor(Color(UIColor.label))
                
                StatusCardView(
                    title: "My Optimus \(user.selectedBot ?? "Bot") Journey",
                    iconName: "shippingbox",
                    iconColor: .orange
                ) {
                    HStack(spacing: 12) {
                        
                        VStack(spacing: 4) {
                            Text("Status")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                                
                            Text(user.productionStatus ?? "???")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if let launchDate = launchDate {
                                Text("Launch scheduled for \(launchDate.formatted(.dateTime.month().day()))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // launchStatus 값에 따라 다른 정보 표시
                        if let status = user.productionStatus {
                            if status == "Before Production" {
                                StatusInfoBox(
                                    title: "Queue",
                                    value: "\(user.waitList)"
                                )
                            } else if status == "Ongoing Production" {
                                StatusInfoBox(
                                    title: "Production",
                                    value: "\(productionProgressPercentage()) %"
                                )
                            } else {
                                StatusInfoBox(
                                    title: "???",
                                    value: "-"
                                )
                            }
                        } else {
                            StatusInfoBox(
                                title: "???",
                                value: "-"
                            )
                        }
                        
                        
                        StatusInfoBox(
                            title: "Arrival exp",
                            value: user.estimatedArrivalAtMarsDate?
                                .formatted(.dateTime.month().day().year()) ?? "Yet to Launch"
                        )
                    }
                }
                
                if let sponsor = user.sponsor, !sponsor.isEmpty {
                    StatusCardView(
                        title: "Sponsorship Info",
                        iconName: "gift",
                        iconColor: .green
                    ) {
                        InfoRow(label: "Project Type", value: sponsor)
                    }
                }
                
                StatusCardView(
                    title: "Earth Statistics",
                    iconName: "globe.americas",
                    iconColor: .blue
                ) {
                    InfoRow(label: "Robot Production Capacity", value: "\(user.productionCapacity) units/day")
                    InfoRow(label: "Required Manufacturing Time", value: "\(user.productionDurationInDays) days")
                }
                
                StatusCardView(
                    title: "Starbase Weather",
                    iconName: "sun.max",
                    iconColor: .yellow
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        if isLoading {
                            ProgressView("Loading...")
                        } else if let forecast = forecast {
                            WeatherView(forecast: forecast)
                        } else if let errorMessage = errorMessage {
                            Text("Error: \(errorMessage)").foregroundColor(.red)
                        } else {
                            Text("Tap to load weather")
                        }
                    }
                }
                
                
            }
            .padding()
        }
        .onAppear {
            Task {
                await loadForecast()
            }
        }
        .background(Color.white)
    }
    
    private func productionProgressPercentage() -> Int {
        guard let startDate = user.productionStartDate else { return 0 }
        let totalDays = user.productionDurationInDays
        guard totalDays > 0 else { return 0 }
        
        let calendar = Calendar.current
        let today = Date()
        
        let daysElapsed = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        
        if daysElapsed < 0 { return 0 }
        
        let progress = Double(daysElapsed) / Double(totalDays) * 100.0
        return Int(min(max(progress, 0.0), 100.0))
    }
    
    private func loadForecast() async {
        isLoading = true
        do {
            forecast = try await downloader.fetchForecast(lat: 30.2672, lon: -97.7431) // Austin
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}


// MARK: - ActivityPositions (ProjectView.swift에서 가져옴)
private class ActivityPositions: ObservableObject {
    @Published var positions: [Int: (top: CGPoint, bottom: CGPoint)] = [:] // Activity ID가 Int라고 가정
    
    func updatePosition(for id: Int, top: CGPoint, bottom: CGPoint) {
        positions[id] = (top, bottom)
    }
    
    func position(for id: Int) -> (top: CGPoint, bottom: CGPoint)? {
        return positions[id]
    }
}


// MARK: - CPM 그래픽 관련 뷰 (ProjectView.swift에서 가져오거나 수정)

private struct GraphicalResultView: View {
    // @Query 대신 Activity 배열을 직접 받도록 수정
    let activities: [Activity] // SwiftData의 Activity 모델 사용
    @EnvironmentObject var activityPositions: ActivityPositions
    
    // Function to group and sort activities by `earlyStart`
    private func groupedAndSortedActivities() -> [[Activity]] {
        guard !activities.isEmpty else { return [] }
        let grouped = Dictionary(grouping: activities) { $0.earlyStart }
        return grouped.sorted { $0.key < $1.key }.map { $0.value.sorted(by: { $0.id < $1.id }) } // 그룹 내에서도 ID로 정렬
    }
    
    var body: some View {
        ZStack {
            if activities.isEmpty {
                Text("표시할 CPM 활동이 없습니다.")
                    .padding()
            } else {
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 20) { // spacing 추가
                        ForEach(groupedAndSortedActivities(), id: \.self) { activityGroup in
                            HStack(spacing: 10) {
                                ForEach(activityGroup) { activity in // id: \.id 제거 (Identifiable이므로)
                                    ActivityBlockView(activity: activity)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    ArrowOverlay(activities: activities) // activities 전달
                }
                .coordinateSpace(name: "ChartSpace")
            }
        }
    }
}

private struct ActivityBlockView: View {
    var activity: Activity // SwiftData의 Activity 모델 사용
    @EnvironmentObject var activityPositions: ActivityPositions
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) { // 내용 정렬 및 간격
            Text("\(activity.name)")
                .font(.caption.bold())
                .foregroundColor(.black)
                .lineLimit(1)
            Text("ID: \(activity.id)")
                .font(.caption2)
                .foregroundColor(.black.opacity(0.8))
            Text("Duration: \(activity.duration)")
                .font(.caption2)
                .foregroundColor(.black.opacity(0.8))
            
            Divider().background(Color.black.opacity(0.5))
            
            HStack {
                Text("ES: \(activity.earlyStart)")
                Spacer()
                Text("EF: \(activity.earlyFinish)")
            }
            .font(.caption2)
            .foregroundColor(.black.opacity(0.9))
            
            HStack {
                Text("LS: \(activity.lateStart)")
                Spacer()
                Text("LF: \(activity.lateFinish)")
            }
            .font(.caption2)
            .foregroundColor(.black.opacity(0.9))
            
            Text("Float: \(activity.totalFloat)")
                .font(.caption2.bold())
                .foregroundColor(activity.totalFloat == 0 ? .orange : .black.opacity(0.9))
            
            
        }
        .padding(8) // 내부 패딩
        .frame(width: 120, height: 150) // 크기 고정 또는 유동적으로
        .background(activity.totalFloat == 0 ? Color(UIColor.systemGray6):Color(UIColor.systemGray4))//Color.red.opacity(0.8) : Color.blue.opacity(0.7))
        .cornerRadius(8)
        .shadow(radius: 3)
        .background(GeometryReader { geometry in
            Color.clear
                .onAppear {
                    let frame = geometry.frame(in: .named("ChartSpace"))
                    let topCenter = CGPoint(x: frame.midX, y: frame.minY)
                    let bottomCenter = CGPoint(x: frame.midX, y: frame.maxY)
                    activityPositions.updatePosition(
                        for: activity.id,
                        top: topCenter,
                        bottom: bottomCenter
                    )
                }
        })
    }
}

private struct ArrowOverlay: View {
    @EnvironmentObject var activityPositions: ActivityPositions
    let activities: [Activity] // @Query 대신 직접 받음
    
    var body: some View {
        Canvas { context, size in
            for activity in activities {
                guard let positions = activityPositions.position(for: activity.id) else {
                    // print("ArrowOverlay: Position not found for activity \(activity.id)")
                    continue
                }
                // Activity 모델에 successors가 Activity 객체 배열로 이미 있다고 가정
                for successorActivity in activity.successors {
                    guard let successorPositions = activityPositions.position(for: successorActivity.id) else {
                        // print("ArrowOverlay: Position not found for successor \(successorActivity.id) of activity \(activity.id)")
                        continue
                    }
                    drawArrow(from: positions.bottom, to: successorPositions.top, in: context)
                }
            }
        }
    }
    
    func drawArrow(from start: CGPoint, to end: CGPoint, in context: GraphicsContext) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        
        let arrowHeadLength: CGFloat = 10 // 화살촉 크기 조정
        let arrowHeadAngle: CGFloat = .pi / 7  // 30도에서 약간 조정
        
        let angle = atan2(end.y - start.y, end.x - start.x)
        
        let arrowPoint1 = CGPoint(
            x: end.x - arrowHeadLength * cos(angle + arrowHeadAngle),
            y: end.y - arrowHeadLength * sin(angle + arrowHeadAngle)
        )
        let arrowPoint2 = CGPoint(
            x: end.x - arrowHeadLength * cos(angle - arrowHeadAngle),
            y: end.y - arrowHeadLength * sin(angle - arrowHeadAngle)
        )
        
        context.stroke(path, with: .color(.black.opacity(0.7)), lineWidth: 1.5) // 라인 스타일 조정
        
        var arrowHead = Path()
        arrowHead.move(to: end)
        arrowHead.addLine(to: arrowPoint1)
        arrowHead.addLine(to: arrowPoint2)
        arrowHead.closeSubpath() // 삼각형 닫기
        
        context.fill(arrowHead, with: .color(.black.opacity(0.7))) // 채우기
    }
}

// MARK: - CPMView 수정
private struct CPMView: View {
    @Environment(\.modelContext) private var modelContext // SwiftData modelContext
    @Bindable var user: User
    
    private let cpmService = CPMService() // CPM 계산 서비스
    @State private var cpmCalculatedActivities: [Activity] = [] // 화면에 표시할 Activity 배열
    @StateObject private var activityPositions = ActivityPositions() // 그래픽 뷰를 위한 위치 관리자
    
    @State private var estimatedArrivalDateString: String = "계산 중..."
    @State private var projectStartDate: Date = Date() // CPM 시작일, 필요에 따라 설정
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX") // 월 이름 영어 고정
        return formatter
    }()
    
    // User 데이터를 기반으로 CPM 액티비티를 구성하고 계산하여 @State 변수를 업데이트하는 함수
    private func calculateAndPrepareCPMData() {
        // 1. User 데이터 기반으로 CPM 계산용 활동 정의 (CPMService가 사용하는 구조체 사용)
        let productionWaitDuration = user.waitList > 0 ? max(1, Int(round(Double(user.waitList) / round(Double(user.productionCapacity))))) : 0
        let robotProductionDays = user.productionDurationInDays // User 모델에 이 필드 필요
        let spaceFlightDuration = (user.selectedBot == "Gen6") ? 203 : 210 // 예시
        
        let serviceActivities: [CPMActivity] = [ // CPMService 내부 구조체 사용 명시
            CPMActivity(id: "1", name: "Awaiting Production", duration: productionWaitDuration, predecessors: []),
            CPMActivity(id: "2", name: "Parts Procurement", duration: 10, predecessors: []),
            
            CPMActivity(id: "3", name: "Robot Production", duration: robotProductionDays, predecessors: ["1", "2"]),
            
            CPMActivity(id: "4", name: "System Integration & Testing", duration: 2, predecessors: ["3"]),
            
            CPMActivity(id: "5", name: "Calibration", duration: 1, predecessors: ["3"]),
            CPMActivity(id: "6", name: "Transport to Launch Site", duration: 3, predecessors: ["4", "5"]),
            CPMActivity(id: "7", name: "Launch Preparation", duration: 1, predecessors: ["6"]),
            CPMActivity(id: "8", name: "Final Systems Check", duration: 1, predecessors: ["6"]),
            CPMActivity(id: "9", name: "Propellant Loading", duration: 1, predecessors: ["6"]),
            CPMActivity(id: "10", name: "Terminal Countdown & Go/No-Go Poll", duration: 1, predecessors: ["6"]),
            CPMActivity(id: "11", name: "Launch", duration: 1, predecessors: ["7", "8", "9", "10"]),
            CPMActivity(id: "12", name: "Ascent & Booster Separation", duration: 0, predecessors: ["11"]),
            CPMActivity(id: "13", name: "Orbital Refueling", duration: 1, predecessors: ["11"]),
            CPMActivity(id: "14", name: "heavy booster earth reentry", duration: 1, predecessors: ["13"]),
            CPMActivity(id: "15", name: "Space Flight", duration: spaceFlightDuration, predecessors: ["13"]),
            CPMActivity(id: "16", name: "Mars Landing", duration: 1, predecessors: ["15"]),
            CPMActivity(id: "17", name: "Calibration", duration: 1, predecessors: ["16"]),
            CPMActivity(id: "18", name: "Delivery Complete", duration: 0, predecessors: ["17"])
        ]
        
        // 2. CPM 계산 실행
        let calculatedServiceActivities = cpmService.calculateCPM(activities: serviceActivities)
        
        // 3. 계산된 결과를 SwiftData의 Activity 모델로 변환
        //    이 과정에서 ID를 Int로, predecessor/successor 관계를 Activity 객체로 매핑해야 합니다.
        //    여기서는 SwiftData에 저장하지 않고 화면 표시용 Activity 객체를 만듭니다.
        var tempActivities: [Activity] = []
        var activityDict: [String: Activity] = [:] // ID 매핑용 딕셔너리
        
        for serviceActivity in calculatedServiceActivities {
            guard let activityIdInt = Int(serviceActivity.id) else { continue } // ID를 Int로 변환
            let newActivity = Activity(
                id: activityIdInt, // Int ID 사용
                name: serviceActivity.name,
                duration: serviceActivity.duration
            )
            newActivity.earlyStart = serviceActivity.earlyStart
            newActivity.earlyFinish = serviceActivity.earlyFinish
            newActivity.lateStart = serviceActivity.lateStart
            newActivity.lateFinish = serviceActivity.lateFinish
            newActivity.totalFloat = serviceActivity.slack
            // freeFloat, actualStart, actualFinish 등은 필요시 추가 계산
            
            tempActivities.append(newActivity)
            activityDict[serviceActivity.id] = newActivity
        }
        
        // Predecessor/Successor 관계 설정
        for serviceActivity in calculatedServiceActivities {
            guard let currentSwiftDataActivity = activityDict[serviceActivity.id] else { continue }
            
            currentSwiftDataActivity.predecessors = serviceActivity.predecessorIDs.compactMap { predIdString in
                activityDict[predIdString]
            }
            currentSwiftDataActivity.successors = serviceActivity.successorIDs.compactMap { succIdString in
                activityDict[succIdString]
            }
        }
        
        self.cpmCalculatedActivities = tempActivities

        var shouldSaveChanges = false // 변경 사항이 있을 때만 저장하기 위한 플래그
        
        // 4. 예상 도착일 계산 및 User 모델 업데이트
        // 최종 활동 ID를 "Delivery Complete"의 ID인 18로 수정합니다.
        if let finalActivity = self.cpmCalculatedActivities.first(where: { $0.id == 18 }) {
            let totalDaysFromProjectStart = finalActivity.earlyFinish
            
            if let arrivalDate = Calendar.current.date(byAdding: .day, value: totalDaysFromProjectStart, to: projectStartDate) {
                self.estimatedArrivalDateString = self.dateFormatter.string(from: arrivalDate) // UI 표시용 문자열 업데이트
                
                // User 모델의 estimatedArrivalAtMarsDate 업데이트 (값이 변경되었을 경우에만)
                if user.estimatedArrivalAtMarsDate != arrivalDate {
                    user.estimatedArrivalAtMarsDate = arrivalDate
                    shouldSaveChanges = true
                }
            } else {
                self.estimatedArrivalDateString = "날짜 계산 오류" //
                if user.estimatedArrivalAtMarsDate != nil { // 기존 날짜가 있었다면 nil로 변경
                    user.estimatedArrivalAtMarsDate = nil
                    shouldSaveChanges = true
                }
            }
        } else {
            self.estimatedArrivalDateString = "계산 불가" //
            if user.estimatedArrivalAtMarsDate != nil { // 기존 날짜가 있었다면 nil로 변경
                user.estimatedArrivalAtMarsDate = nil
                shouldSaveChanges = true
            }
        }
        
        // 변경 사항이 있을 경우에만 modelContext.save() 호출 및 로그 기록
        if shouldSaveChanges {
            do {
                try modelContext.save()
                print("CPM Update: User data saved successfully for user '\(user.name)'. Estimated arrival: \(user.estimatedArrivalAtMarsDate != nil ? dateFormatter.string(from: user.estimatedArrivalAtMarsDate!) : "N/A")")
            } catch {
                print("Error: Failed to save user data after CPM update: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Order Status")
                    .font(.headline)
                    .padding(.horizontal)
                    .foregroundColor(Color(UIColor.label))
                
                StatusCardView( // 기존 StatusCardView 재활용 또는 CPM 전용 카드 생성
                    title: "Major Events",
                    iconName: "calendar.day.timeline.left",
                    iconColor: .cyan
                ) {
                    VStack(alignment: .leading) {
                        InfoRow(label: "Order Date", value: projectStartDate.formatted(date: .abbreviated, time: .omitted))
                        InfoRow(label: "Expected Arrival", value: estimatedArrivalDateString)
                    }
                }
                .padding(.horizontal)
                
                StatusCardView(
                    title: "CPM Graphic",
                    iconName: "cart",
                    iconColor: .orange
                ) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if !cpmCalculatedActivities.isEmpty {
                                GraphicalResultView(activities: cpmCalculatedActivities)
                                    .fixedSize(horizontal: true, vertical: true)
                                    .environmentObject(activityPositions)
                            } else {
                                Text("CPM 데이터를 로드 중이거나, 표시할 활동이 없습니다.")
                                    .padding()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical) // 전체 VStack에 대한 수직 패딩
        }
        .onAppear {
            calculateAndPrepareCPMData()
        }
        .background(Color.white) // 배경색 일관성 유지
    }
}




// MARK: - MenuView 정의

private func MenuView(user: User, modelContext: ModelContext, logoutAction: @escaping () -> Void) -> some View {
    ScrollView {
        VStack {
            Spacer()
            
            Button(action: {
                modelContext.delete(user)
                do {
                    try modelContext.save()
                    logoutAction()
                } catch {
                    print("⚠️ 사용자 삭제 실패: \(error.localizedDescription)")
                }
                logoutAction()
            }) {
                Text("Log out")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.white)
    }
}
struct EarthSearchView: View {
    @State private var searchText: String = ""
    @State private var searchURL: URL? // 웹뷰에 로드할 URL 상태 변수
    @State private var isLoadingWebView: Bool = false // 웹뷰 로딩 상태 (선택 사항)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // spacing을 0으로 조정하고 내부에서 패딩 관리
            // 검색창 및 검색 버튼
            HStack {
                TextField("Google에서 검색...", text: $searchText, onCommit: performSearch)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Button(action: performSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                }
                .padding(.leading, 5)
            }
            .padding(.horizontal)
            .padding(.top) // VStack의 .padding(.top)을 HStack으로 이동
            .padding(.bottom, 10) // 검색창 아래 약간의 여백

            // 웹뷰 또는 플레이스홀더 텍스트
            if let url = searchURL {
                ZStack {
                    WebView(url: url) // 정의한 WebView 사용
                    if isLoadingWebView { // 선택적 로딩 인디케이터
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // 웹뷰 로드 시작/종료 시 isLoadingWebView 상태를 변경하려면 WebView의 Coordinator 사용 필요
            } else {
                VStack { // 플레이스홀더 텍스트를 중앙에 배치하기 위한 VStack
                    Spacer()
                    if !searchText.isEmpty {
                        Text("'\(searchText)'에 대한 검색 결과를 보려면 Enter 또는 검색 버튼을 누르세요.")
                            .padding(.horizontal)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Google에서 검색할 내용을 입력하세요.")
                            .padding(.horizontal)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white) // 전체 배경색
        // .padding(.top) // 이 패딩은 HStack으로 옮김
    }

    private func performSearch() {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else {
            searchURL = nil // 검색어가 비어있으면 웹뷰 숨김
            return
        }

        if let encodedQuery = trimmedSearchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
            searchURL = url
            // isLoadingWebView = true // 웹뷰 로딩 시작 (Coordinator와 연동 필요)
        } else {
            searchURL = nil
            // 여기에 URL 생성 실패에 대한 사용자 알림 추가 가능
            print("Error: Could not create search URL for query: \(trimmedSearchText)")
        }
        // 키보드 내리기 (선택 사항)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


private func SearchView() -> some View {
    @State var searchText: String = ""

    return VStack(alignment: .leading, spacing: 16) {
        // 검색창
        TextField("Search anything...", text: $searchText)
            .padding(10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .foregroundColor(.primary)
            .font(.body)
        
        // 결과 영역 (현재는 입력 텍스트 출력)
        if !searchText.isEmpty {
            Text("You searched for: \(searchText)")
                .padding(.horizontal)
                .foregroundColor(.secondary)
        } else {
            Text("Try typing something above.")
                .padding(.horizontal)
                .foregroundColor(.secondary)
        }
        
        Spacer()
    }
    .padding(.top)
    .background(Color.white)
}


private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // 웹뷰의 탐색 동작을 관리하기 위한 델리게이트 설정 (선택 사항)
        // webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    // Coordinator 클래스는 웹뷰의 탐색 이벤트를 처리할 때 필요할 수 있습니다. (선택 사항)
    // func makeCoordinator() -> Coordinator {
    //     Coordinator(self)
    // }
    //
    // class Coordinator: NSObject, WKNavigationDelegate {
    //     var parent: WebView
    //
    //     init(_ parent: WebView) {
    //         self.parent = parent
    //     }
    //
    //     // 예: 페이지 로딩 완료 시 호출
    //     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    //         print("Webview did finish loading page")
    //     }
    // }
}

// StatusInfoBox 헬퍼 뷰 (라이트 모드 스타일 명시)
private struct StatusInfoBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.label))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(12)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}


private struct StatusCardView<Content: View>: View {
    let title: String
    let iconName: String
    let iconColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(UIColor.label)) // 라이트 모드용 텍스트 색상
                Spacer()
            }
            Divider()
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    init(label: String, value: Date, style: Date.FormatStyle) {
        self.label = label
        self.value = value.formatted(style)
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color(UIColor.secondaryLabel))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.label))
        }
    }
}


// EarthSideView_Previews 등 나머지 코드는 이전 답변을 참고하여 유지합니다.
#if DEBUG
struct EarthSideView_Previews: PreviewProvider { // Preview 코드 업데이트
    @State static var previewPath: [Route] = []
    static var sampleUser: User = {
        let user = User(id: "earthUserPreview", name: "지구시민 프리뷰", phoneNumber: "01000000000")
        user.selectedBot = "Gen7 Preview"
        return user
    }()
    
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: User.self, configurations: config)
        container.mainContext.insert(sampleUser)
        
        return NavigationStack {
            EarthSideView(path: $previewPath, user: sampleUser, logoutAction: {
                print("Preview Logout Tapped")
            })
            .modelContainer(container)
        }
    }
}
#endif
