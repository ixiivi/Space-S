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
    @Binding var path: [Route]
    @State private var selectedTab: EarthTab = .home

    enum EarthTab: CaseIterable, Identifiable {
        case home, calendar, changeView, explore, menu

        var id: Self { self }
        var iconName: String {
            switch self {
            case .home: "house"
            case .calendar: "calendar"
            case .changeView: "plus.circle"
            case .explore: "magnifyingglass"
            case .menu: "line.horizontal.3"
            }
        }
        var title: String {
            switch self {
            case .home: "Home"
            case .calendar: "Calendar"
            case .changeView: "Perspective"
            case .explore: "Search"
            case .menu: "Menu"
            }
        }
    }

    init(path: Binding<[Route]>, user: User) {
        self._path = path
        self.user = user
    }

    var body: some View {
        VStack(spacing: 0) {
            minimalistTopBar()

            TabView(selection: $selectedTab) {
                EarthHomeContentView(user: user)
                    .tag(EarthTab.home)
                Text("Calendar").tag(EarthTab.calendar)
                Text("Search").tag(EarthTab.explore)
                Text("Menu").tag(EarthTab.menu)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            minimalistTabBar()
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
    }

    private func minimalistTopBar() -> some View {
        HStack {
            Text("Earth")
                .font(.system(size: 20, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
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
                            .foregroundColor(selectedTab == tab ? .accentColor : .gray)
                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == tab ? .accentColor : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
    }
}

struct EarthHomeContentView: View {
    @Bindable var user: User
    let totalEarthUsersSendingRobots = 12345

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hello, \(user.name)!")
                    .font(.headline)
                    .padding(.horizontal)

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
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        
                        // Queue Number Box
                        VStack(spacing: 4) {
                            Text("Queue Number")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Text("\(user.waitList)번째")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        
                        // Expected Arrival Box
                        VStack(spacing: 4) {
                            Text("Expected Arrival")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Text(user.estimatedArrivalAtMarsDate?
                                .formatted(.dateTime.month().day().year()) ?? "Yet to Launch")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                }

                if let sponsor = user.sponsor, !sponsor.isEmpty {
                    StatusCardView(
                        title: "스폰서십 정보",
                        iconName: "gift.fill",
                        iconColor: .green
                    ) {
                        InfoRow(label: "프로젝트", value: sponsor)
                    }
                }

                StatusCardView(
                    title: "지구 통계",
                    iconName: "globe.americas",
                    iconColor: .blue
                ) {
                    InfoRow(label: "총 발송 인원", value: "\(totalEarthUsersSendingRobots) 명")
                }
            }
            .padding()
        }
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
                Spacer()
            }
            Divider()
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
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

