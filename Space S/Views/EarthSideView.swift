//
//  EarthSideView.swift
//  Space S
//
//  Created by 김재현 on 5/29/25.
// 이 파일

import SwiftUI
import SwiftData

struct EarthSideView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User
    @Binding var path: [Route]
    @State private var selectedTab: EarthTab = .home
    let logoutAction: () -> Void // 로그아웃 액션 클로저 추가
    
    enum EarthTab: CaseIterable, Identifiable {
        case home, cpm, changeView, explore, menu
        
        var id: Self { self }
        var iconName: String {
            switch self {
            case .home: "house"
            case .cpm: "calendar"
            case .changeView: "plus.circle"
            case .explore: "magnifyingglass"
            case .menu: "line.horizontal.3"
            }
        }
        var title: String {
            switch self {
            case .home: "Home"
            case .cpm: "CPM"
            case .changeView: "Perspective"
            case .explore: "Search"
            case .menu: "Menu"
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
                Text("Search").tag(EarthTab.explore)
                Text("Menu").tag(EarthTab.menu)
                
                //MenuView(user: user, path: $path, logoutAction: logoutAction)
                    .tag(EarthTab.menu)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            minimalistTabBar()
        }
        .background(Color.white) // 전체 배경을 흰색으로 명시
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .environment(\.colorScheme, .light) // 루트 뷰에 라이트 모드 환경 강제
    }
    
    private func minimalistTopBar() -> some View {
        HStack {
            Text("Earth")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(UIColor.label)) // 라이트 모드에 맞는 기본 텍스트 색상
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6)) // 명시적인 밝은 배경색
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
                            .foregroundColor(selectedTab == tab ? Color.accentColor : Color(UIColor.darkGray)) // 비활성 시 명시적 어두운 회색
                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == tab ? Color.accentColor : Color(UIColor.darkGray)) // 비활성 시 명시적 어두운 회색
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 8) // Safe area 존중
        .background(Color(UIColor.systemGray6)) // 명시적인 밝은 배경색
    }
}

struct EarthHomeContentView: View {
    @State private var launchDate: Date? = nil
    @Bindable var user: User
    let totalEarthUsersSendingRobots = 11095
    //@StateObject var locationManager = LocationManager()
    @State var openWeatherResponse : OpenWeatherResponse?// 현재 날씨 데이터
    @State var oneCallWeatherResponse: OneCallResponse?  // 주간 예보 포함 전체 응답 (daily 추출용)
    @State var isLoadingWeather: Bool = false
    @State var weatherError: Error? = nil
    var weatherDataDownload = WeatherDataDownload()
    @StateObject var locationManager = LocationManager()
    private let austinLatitude: Double = 30.2672
    private let austinLongitude: Double = -97.7431
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hello, \(user.name)!")
                    .font(.headline)
                    .padding(.horizontal)
                    .foregroundColor(Color(UIColor.label)) // 라이트 모드에 적합한 텍스트 색상
                
                StatusCardView(
                    title: "My Optimus \(user.selectedBot ?? "Bot") Journey",
                    iconName: "shippingbox",
                    iconColor: .orange
                ) {
                    HStack(spacing: 12) {
                        
                        // Shipment Status Box
                        VStack(spacing: 4) {
                            Text("Shipment Status")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text(user.productionStatus ?? "Ongoing Production")
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
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        
                        StatusInfoBox(
                            title: "Queue Number",
                            value: "\(user.waitList)"
                        )
                        
                        StatusInfoBox(
                            title: "Expected Arrival",
                            value: user.estimatedArrivalAtMarsDate?
                                .formatted(.dateTime.month().day().year()) ?? "Yet to Launch"
                        )
                    }
                }
                
                if let sponsor = user.sponsor, !sponsor.isEmpty {
                    StatusCardView(
                        title: "Sponsorship Info",
                        iconName: "gift.fill",
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
                    InfoRow(label: "Robot Production Capacity", value: "5000 units/day")
                }
                
                StatusCardView(
                    title: "Starbase, Texas Weather",
                    iconName: "sun.max",
                    iconColor: .yellow
                ) {
                    VStack(alignment: .leading, spacing: 10) { // 날씨 정보를 담을 VStack
                        if isLoadingWeather {
                            ProgressView("날씨 정보 로딩 중...")
                                .padding()
                        } else if let error = weatherError {
                            Text("날씨 정보를 가져오지 못했습니다: \(error.localizedDescription)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            // 현재 날씨 표시
                            if let currentWeatherData = openWeatherResponse {
                                Text("현재 날씨")
                                    .font(.headline)
                                // WeatherView를 사용하거나 직접 UI 구성
                                WeatherView(openWeatherResponse: currentWeatherData)
                                    .padding(.bottom)
                            } else {
                                Text("현재 날씨 정보를 불러올 수 없습니다.")
                                    .font(.caption)
                            }
                            
                            Divider()
                                .padding(.vertical, 5)
                            
                            // 주간 예보 표시
                            if let dailyForecasts = oneCallWeatherResponse?.daily, !dailyForecasts.isEmpty {
                                Text("주간 예보")
                                    .font(.headline)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(dailyForecasts.prefix(7)) { dayForecast in // 최대 7일치 표시
                                            DailyWeatherCell(
                                                forecast: FormattedDailyForecast(
                                                    dailyForecast: dayForecast,
                                                    timezoneIdentifier: oneCallWeatherResponse?.timezone // OneCall 응답의 시간대 정보 사용
                                                )
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            } else {
                                Text("주간 예보 정보를 불러올 수 없습니다.")
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                
            }
            .padding()
        }
        .onAppear {
            //launchDate = LaunchScheduleLoader.loadLaunchDate()
        }
        .background(Color.white)
    }
}

struct DailyWeatherCell: View {
    let forecast: FormattedDailyForecast

    var body: some View {
        VStack(spacing: 8) {
            Text(forecast.dayOfWeek) // 예: "월"
                .font(.caption.weight(.medium))
            if let iconURL = forecast.iconURL {
                 AsyncImage(url: iconURL) { image in
                     image.resizable()
                 } placeholder: {
                     ProgressView()
                 }
                 .frame(width: 40, height: 40)
            } else {
                Text(forecast.weatherCondition.first?.description.uppercased() ?? "?") // 아이콘 대신 텍스트 (예: "☀️")
                     .font(.title2)
            }
            Text("\(forecast.tempMaxCelsius ?? 0)°")
                .font(.body.weight(.semibold))
            Text("\(forecast.tempMinCelsius ?? 0)°")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct CPMView: View {
    @State private var launchDate: Date? = nil
    @Bindable var user: User
    let totalEarthUsersSendingRobots = 11095
    // CPM 서비스를 위한 인스턴스
    private let cpmService = CPMService()
    // 계산된 예상 도착 날짜를 저장할 상태 변수
    @State private var estimatedArrivalDateString: String = "계산 중..."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Order")
                    .font(.headline)
                    .padding(.horizontal)
                    .foregroundColor(Color(UIColor.label)) // 라이트 모드에 적합한 텍스트 색상
                
                StatusCardView(
                    title: "My Optimus \(user.selectedBot ?? "Bot") Journey",
                    iconName: "shippingbox",
                    iconColor: .orange
                ) {
                    HStack(spacing: 12) {
                        
                        // Shipment Status Box
                        VStack(spacing: 4) {
                            Text("Shipment Status")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text(user.productionStatus ?? "Ongoing Production")
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
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        
                        StatusInfoBox(
                            title: "Queue Number",
                            value: "\(user.waitList)"
                        )
                        
                        StatusInfoBox(
                            title: "Expected Arrival",
                            value: user.estimatedArrivalAtMarsDate?
                                .formatted(.dateTime.month().day().year()) ?? "Yet to Launch"
                        )
                    }
                }
            }
            .padding()
        }
        .onAppear {
            launchDate = LaunchScheduleLoader.loadLaunchDate()
        }
        .background(Color.white)
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

// MARK: - MenuView 정의

//struct MenuView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Bindable var user: User // 현재 사용자 정보
//    @Binding var path: [Route] // 네비게이션 경로 (로그아웃 시 초기화용이지만, 실제 초기화는 logoutAction에서)
//    let logoutAction: () -> Void // AppView에서 전달받은 로그아웃 처리 함수
//
//    // 메뉴 항목 데이터 구조체 (예시)
//    struct MenuItem: Identifiable {
//        let id = UUID()
//        let name: String
//        let iconName: String
//        let destination: AnyView? // 실제 이동할 뷰 (지금은 nil)
//
//        init(name: String, iconName: String, destination: AnyView? = nil) {
//            self.name = name
//            self.iconName = iconName
//            self.destination = destination
//        }
//    }
//
//    // 예시 메뉴 항목들
//    let menuItems1: [MenuItem] = [
//        MenuItem(name: "토스프라임 멤버십", iconName: "star.fill"),
//        MenuItem(name: "연금 준비", iconName: "figure.walk"),
//        MenuItem(name: "사장님·광고", iconName: "person.badge.shield.checkmark.fill"),
//        MenuItem(name: "머니라운지", iconName: "message.fill"),
//        MenuItem(name: "멤버십 포인트", iconName: "p.circle.fill"),
//        MenuItem(name: "편의점 택배", iconName: "shippingbox.fill")
//    ]
//
//    let menuItems2: [MenuItem] = [
//        MenuItem(name: "내 토스인증서", iconName: "checkmark.shield.fill")
//    ]
//
//    let menuItems3: [MenuItem] = [
//        MenuItem(name: "토스 계정 통합 서비스", iconName: "arrow.triangle.2.circlepath.circle.fill"),
//        MenuItem(name: "24시간 고객센터", iconName: "headphones.circle.fill"),
//        MenuItem(name: "토스 새소식", iconName: "megaphone.fill"),
//        MenuItem(name: "스크린리더 새소식", iconName: "accessibility.fill")
//    ]
//
//    var body: some View {
//        NavigationView { // MenuView 자체 네비게이션 바를 위해 추가 (선택적)
//            VStack(spacing: 0) {
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 0) {
//                        // 섹션 1
//                        menuSection(items: menuItems1, header: "토스 서비스")
//
//                        // 섹션 2: 편의
//                        menuSection(items: menuItems2, header: "편의")
//
//                        // 섹션 3: 도움말
//                        menuSection(items: menuItems3, header: "도움말")
//
//                        Spacer(minLength: 30) // 로그아웃 버튼 위의 여백
//                    }
//                }
//
//                // 로그아웃 버튼 (화면 하단에 위치)
//                Button(action: {
//                    // 1. 사용자 데이터 삭제
//                    modelContext.delete(user)
//                    do {
//                        try modelContext.save()
//                        Logger.logInfo("User \(user.id) data deleted successfully.") // Logger가 정의되어 있다고 가정
//                    } catch {
//                        Logger.logError("Failed to delete user \(user.id) data: \(error.localizedDescription)")
//                    }
//
//                    // 2. AppView의 로그아웃 처리 함수 호출 (path 초기화 및 로딩화면으로 전환)
//                    logoutAction()
//                }) {
//                    Text("로그아웃")
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color(UIColor.systemGray5)) // 라이트모드에 맞는 배경
//                        .foregroundColor(Color.red)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 10) // 하단 여백
//            }
//            .background(Color.white) // MenuView 배경색
//            .navigationTitle("전체")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { // 상단 검색, 설정 아이콘 (UI만)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    HStack {
//                        Button(action: {}) { Image(systemName: "magnifyingglass") }
//                        Button(action: {}) { Image(systemName: "gearshape.fill") }
//                    }
//                    .foregroundColor(Color(UIColor.label)) // 라이트 모드 아이콘 색상
//                }
//            }
//        }
//        .environment(\.colorScheme, .light) // MenuView도 라이트모드 강제
//        // NavigationView를 사용한다면, EarthSideView의 .navigationBarHidden(true)와 충돌하지 않도록
//        // EarthSideView의 TabView 내에서 MenuView를 감싸는 NavigationView는 제거하거나 조건부로 처리해야 할 수 있습니다.
//        // 여기서는 MenuView가 자체적으로 네비게이션 바를 가지도록 했습니다.
//        // EarthSideView 전체가 .navigationBarHidden(true)이므로, 이 NavigationView는 나타나지 않을 수 있습니다.
//        // 이 경우, .navigationTitle, .toolbar 등은 효과가 없을 수 있으며, 커스텀 헤더를 만들어야 합니다.
//        // 더 간단하게는 NavigationView 없이 VStack과 ScrollView만 사용하고, 헤더는 EarthSideView의 topBar를 공유하거나 자체적으로 만듭니다.
//        // 지금은 우선 요청하신 메뉴 목록과 로그아웃 버튼 구현에 집중했습니다.
//        // 만약 EarthSideView의 minimalistTopBar를 사용하고 싶다면, MenuView의 NavigationView를 제거하고,
//        // 제목 "전체"는 EarthSideView의 topBar가 동적으로 변경되도록 처리해야 합니다.
//        // 가장 간단한 접근은 MenuView 내 NavigationView를 사용하지 않고, 콘텐츠만 VStack에 담는 것입니다.
//        // 이 경우, 아래와 같이 수정합니다.
//        /*
//         // -- NavigationView 없는 버전의 body 시작 --
//         VStack(spacing: 0) {
//             // 커스텀 헤더 (필요시)
//             HStack {
//                 Text("전체") // 또는 EarthSideView의 topBar와 연동
//                     .font(.system(size: 20, weight: .semibold))
//                     .foregroundColor(Color(UIColor.label))
//                 Spacer()
//                 HStack {
//                     Button(action: {}) { Image(systemName: "magnifyingglass") }
//                     Button(action: {}) { Image(systemName: "gearshape.fill") }
//                 }
//                 .foregroundColor(Color(UIColor.label))
//             }
//             .padding()
//             .background(Color(UIColor.systemGray6))
//
//
//             ScrollView {
//                 // ... (menuSection 로직 동일) ...
//             }
//
//             // ... (로그아웃 버튼 로직 동일) ...
//         }
//         .background(Color.white)
//         .environment(\.colorScheme, .light)
//         // -- NavigationView 없는 버전의 body 끝 --
//         */
//    }
//
//    // 메뉴 섹션 헬퍼 뷰
//    private func menuSection(items: [MenuItem], header: String? = nil) -> some View {
//        VStack(alignment: .leading, spacing: 0) {
//            if let header = header, !header.isEmpty {
//                Text(header)
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//                    .padding(.top, 20)
//                    .padding(.bottom, 8)
//            }
//            ForEach(items) { item in
//                Button(action: {
//                    // 각 메뉴 아이템 클릭 시 동작 (현재는 없음)
//                    print("\(item.name) clicked")
//                }) {
//                    HStack(spacing: 16) {
//                        Image(systemName: item.iconName)
//                            .font(.system(size: 20))
//                            .frame(width: 24)
//                            .foregroundColor(Color(UIColor.darkGray)) // 아이콘 색상
//                        Text(item.name)
//                            .font(.system(size: 16))
//                            .foregroundColor(Color(UIColor.label)) // 텍스트 색상
//                        Spacer()
//                        // 부가 정보 (예: "최대 4% 캐시백") 등은 필요시 추가
//                        Image(systemName: "chevron.right") // 오른쪽 화살표
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.gray.opacity(0.5))
//                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 14)
//                }
//                Divider().padding(.leading, 50) // 아이콘 너비만큼 들여쓰기 된 Divider
//            }
//        }
//    }
//}

// StatusInfoBox 헬퍼 뷰 (라이트 모드 스타일 명시)
struct StatusInfoBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color(UIColor.secondaryLabel)) // 라이트 모드용 보조 텍스트 색상
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.label)) // 라이트 모드용 주요 텍스트 색상
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(12)
        .background(Color(UIColor.systemGray5)) // 명시적인 밝은 회색 배경 (라이트 모드)
        .cornerRadius(10)
    }
}


struct StatusCardView<Content: View>: View {
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
        .shadow(color: Color.black.opacity(0.09), radius: 5, x: 0, y: 2)
    }
}

struct InfoRow: View {
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
                .foregroundColor(Color(UIColor.secondaryLabel)) // 라이트 모드용 보조 텍스트 색상
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.label)) // 라이트 모드용 주요 텍스트 색상
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
