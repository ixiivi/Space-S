//
//  EarthSideView.swift
//  Space S
//
//  Created by 김재현 on 5/29/25.
//

import SwiftUI
import SwiftData

struct EarthSideView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User
    @Binding var path: [Route] // 네비게이션 경로
    
    // 선택된 탭을 관리하기 위한 상태 변수
    @State private var selectedTab: EarthTab = .home
    
    // 탭 종류를 정의하는 열거형
    enum EarthTab: CaseIterable, Identifiable {
        case home, calendar, changeView, explore, menu
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .home: "홈"
            case .calendar: "달력"
            case .changeView: "뷰 전환"
            case .explore: "탐색"
            case .menu: "전체"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: "house.fill"
            case .calendar: "calendar"
            case .changeView: "arrow.triangle.2.circlepath.circle"
            case .explore: "safari.fill"
            case .menu: "line.3.horizontal"
            }
        }
    }
    
    init(path: Binding<[Route]>, user: User) {
        self._path = path
        self.user = user
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 커스텀 네비게이션 바 (앱 이름 또는 현재 탭 이름 표시)
            earthTopNavigationBar()
            
            // 선택된 탭에 따라 다른 콘텐츠 표시
            TabView(selection: $selectedTab) {
                EarthHomeContentView(user: user)
                    .tag(EarthTab.home)
                
                Text("달력 (Calendar View - Placeholder)")
                    .tag(EarthTab.calendar)
                
                //                Text("검색 (Search View - Placeholder)")
                //                    .tag(EarthTab.search)
                
                Text("탐색 (Explore View - Placeholder)")
                    .tag(EarthTab.explore)
                
                Text("전체메뉴 (Menu View - Placeholder)")
                    .tag(EarthTab.menu)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // 스와이프 제스처로 탭 전환 방지 및 인디케이터 숨김
            .animation(.easeInOut, value: selectedTab) // 탭 전환 애니메이션
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 콘텐츠 영역이 남은 공간 모두 차지
            
            // 하단 커스텀 탭 바
            earthBottomTabBar()
        }
        .background(Color(UIColor.systemGray6)) // 전체 배경을 밝은 회색으로
        .ignoresSafeArea(.keyboard) // 키보드 올라올 때 UI 밀림 방지
        .navigationBarHidden(true) // SwiftUI 네비게이션 바 숨김 (커스텀 바 사용)
        .onAppear{
            Logger.logInfo("EarthSideView appeared for user: \(user.name)")
    
    
    // 상단 네비게이션 바 (커스텀)
    @ViewBuilder
    private func earthTopNavigationBar() -> some View {
        HStack {
            Text(selectedTab.title) // 현재 선택된 탭의 제목 표시
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.blue) // 포인트 컬러
            
            Spacer()
            
            Button(action: {
                // 알림 버튼 액션 (예시)
                print("알림 버튼 탭")
            }) {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white.shadow(color: .black.opacity(0.05), radius: 2, y: 2)) // 약간의 그림자 효과
    }
    
    // 하단 탭 바 (커스텀)
    @ViewBuilder
    private func earthBottomTabBar() -> some View {
        HStack {
            ForEach(EarthTab.allCases) { tab in Button(action: {
                if tab == .changeView {
                    // "뷰 전환" 탭을 누르면 SelectEarthMarsView로 이동
                    Logger.logInfo("Navigating back to SelectEarthMarsView for user \(user.name)")
                    path.append(Route.selectDestination(user: self.user))
                } else {
                    // 다른 탭들은 selectedTab 상태를 업데이트
                    selectedTab = tab
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: tab.iconName)
                        .font(.system(size: 22))
                    Text(tab.title)
                        .font(.caption2)
                }
                // "뷰 전환" 탭은 항상 선택되지 않은 것처럼 보이게 하거나,
                // 또는 일반 탭처럼 보이되, 눌렀을 때 selectedTab을 바꾸지 않고 액션만 수행하도록 함.
                // 현재는 selectedTab에 따라 색상 변경, changeView는 selectedTab을 바꾸지 않으므로 항상 기본색.
                // 만약 changeView도 눌렀을 때 시각적 피드백(예: 잠깐 색 변경)을 원한다면 별도 처리 필요.
                .foregroundColor(selectedTab == tab && tab != .changeView ? .blue : .gray)
                .frame(maxWidth: .infinity)
            }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 10)
        .background(Color.white.shadow(color: .black.opacity(0.05), radius: 2, y: -2))
    }
    
    // --- 홈 탭에 표시될 콘텐츠 뷰 ---
    struct EarthHomeContentView: View {
        @Bindable var user: User
        
        // 임시 데이터 (실제로는 서버나 다른 곳에서 가져와야 함)
        let totalEarthUsersSendingRobots: Int = 12345
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("안녕하세요, \(user.name)님!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    
                    // 1. 로봇 생산/배송 상태 카드
                    StatusCardView(
                        title: "나의 Optimus \(user.selectedBot ?? "Bot")",
                        iconName: "shippingbox.fill",
                        iconColor: .orange
                    ) {
                        InfoRow(label: "현재 상태", value: user.productionStatus ?? "생산 대기 중")
                        InfoRow(label: "생산 대기 순번", value: "\(user.waitList) 번째")
                        if let etaProd = user.estimatedProductionCompleteDate {
                            InfoRow(label: "예상 생산 완료", value: etaProd, style: .dateTime.month().day().year())
                        }
                        if let etaMars = user.estimatedArrivalAtMarsDate {
                            InfoRow(label: "화성 도착 예상", value: etaMars, style: .dateTime.month().day().year())
                        } else {
                            InfoRow(label: "화성 도착 예상", value: "미정 (발사 후 결정)")
                        }
                    }
                    

                    // 2. 스폰서십 정보 카드 (스폰서 정보가 있을 경우)
                    if let sponsorName = user.sponsor, !sponsorName.isEmpty {
                        StatusCardView(
                            title: "스폰서십 정보",
                            iconName: "gift.fill",
                            iconColor: .green
                        ) {
                            InfoRow(label: "후원 프로젝트", value: sponsorName)
                            // 여기에 스폰서십 관련 추가 정보 표시 가능
                        }
                    }
                    
                    // 3. 지구 전체 통계 카드
                    StatusCardView(
                        title: "지구 발송 현황",
                        iconName: "globe.americas.fill",
                        iconColor: .blue
                    ) {
                        InfoRow(label: "총 로봇 발송 인원", value: "\(totalEarthUsersSendingRobots) 명")
                        // 여기에 추가적인 지구 통계 정보 표시 가능
                    }
                    
                    // TODO: CPM 차트 또는 상세 일정 관련 뷰 추가
                    // Text("상세 일정 (CPM) - 준비 중")
                    //    .font(.headline)
                    //    .padding(.top)
                    
                }
                .padding() // ScrollView 내부 VStack 패딩
            }
            .background(Color(UIColor.systemGray6)) // 홈 콘텐츠 배경색
        }
    }
    
    // --- 정보 카드 스타일을 위한 셔드 뷰 ---
    struct StatusCardView<Content: View>: View {
        let title: String
        let iconName: String
        let iconColor: Color
        @ViewBuilder let content: Content
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Divider()
                
                content // 여기에 InfoRow들이 들어감
            }
            .padding()
            .background(Color.white) // 카드 배경색
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // 카드 그림자
        }
    }
    
    // --- 카드 내 정보 행을 위한 헬퍼 뷰 ---
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
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
    }
    
    
    // Preview
#if DEBUG
    struct EarthSideView_Previews: PreviewProvider {
        @State static var previewPath: [Route] = []
        static var sampleUser: User = {
            let user = User(id: "earthUser", name: "지구시민", phoneNumber: "01012345678")
            user.selectedBot = "Gen7"
            user.waitList = 123
            user.productionStatus = "부품 수급 중"
            user.estimatedProductionCompleteDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
            user.sponsor = "화성 정착촌 식수 공급 프로젝트"
            // estimatedArrivalAtMarsDate는 실제로는 더 복잡한 계산 필요
            user.estimatedArrivalAtMarsDate = Calendar.current.date(byAdding: .month, value: 9, to: Date())
            return user
        }()
        
        static var previews: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: User.self, configurations: config)
            container.mainContext.insert(sampleUser)
            
            return NavigationStack { // Preview에서는 NavigationStack으로 감싸서 확인
                EarthSideView(path: $previewPath, user: sampleUser)
                    .modelContainer(container)
            }
        }
    }
#endif
    //import SwiftUI
    //import SwiftData
    //
    //struct EarthSideView: View {
    //    @Environment(\.modelContext) private var modelContext
    //    @Bindable var user: User
    //    @Binding var path: [Route]
    //    init(path: Binding<[Route]>, user: User) {
    //        self._path = path
    //        self.user = user
    //    }
    //
    //    var body: some View {
    //        ZStack {
    //            Color.white.ignoresSafeArea()
    //            VStack {
    //                Image(systemName: "globe")
    //                    .imageScale(.large)
    //                    .foregroundStyle(.tint)
    //                Text("Earth")
    //                    .foregroundColor(.gray)
    //            }
    //            .padding()
    //            .onAppear{
    //                EarthSideTest(user: user)
    //            }
    //        }
    //    }
    //
    //    func EarthSideTest(user: User){
    //        // --- 사용자 정보 출력 시작 ---
    //        print("--- New User Information ---")
    //        print("ID: \(user.id)")
    //        print("Name: \(user.name)")
    //        print("Phone Number: \(user.phoneNumber)")
    //        print("Selected Bot Model: \(user.selectedBot ?? "N/A")")
    //        print("Sponsor: \(user.sponsor ?? "N/A")")
    //        print("Waiting Number: \(user.waitList)")
    //        //print("Created At: \(newUser.createdAt)")
    //        //print("Destination: \(newUser.destination ?? "N/A")")
    //        print("Is Fully Setup: \(user.isFullySetup)")
    //        print("---------------------------")
    //        // --- 사용자 정보 출력 끝 ---
    //        Logger.logInfo("App started successfully.")
    //    }
    //}
    
    
    //#Preview {
    //    ContentView()
    //}
