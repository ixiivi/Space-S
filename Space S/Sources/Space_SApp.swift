//
//  CM_term_projectApp.swift
//  CM term project
//
//  Created by 김재현 on 5/2/25.
//

import SwiftUI
import SwiftData

enum Route: Hashable {
    case buyBot(user: User)
    case order(user: User, model: String)
    case orderComplete(user: User)
    case selectDestination(user: User)
    case earthSideView(user: User)
    case marsSideView(user: User)
}

struct AppView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \User.id, order: .reverse) private var users: [User]
    @State private var isLoadingComplete = false
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                if !isLoadingComplete {
                    LoadingView(isLoadingComplete: $isLoadingComplete)
                } else {
                    if let user = users.first(where: { $0.isFullySetup }) {
                            SelectEarthMarsView(path: $path, user: user)
                    } else {
                        LoginView(path: $path)
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .buyBot(let user):
                    BuyBotMainView(path: $path , currentUser: user)
                case .order(let userForOrder, let modelForOrder):
                    BuyBotOrderView(path: $path, currentUser: userForOrder, model: modelForOrder)
                case .orderComplete(let user):
                    OrderCompleteView(path: $path, user: user)
                case .selectDestination(let user):
                    SelectEarthMarsView(path: $path, user: user)
                case .earthSideView(let user):
                    EarthSideView(path: $path, user: user, logoutAction: logoutAndResetApp)
                case .marsSideView(let user):
                    MarsSideView(path: $path, user: user)
                    
                }
                
                
                
            }
        }
    }
    func logoutAndResetApp() {
            // User 데이터 삭제는 MenuView에서 modelContext를 사용해 직접 처리합니다.
            // 여기서는 네비게이션 경로를 초기화하고 로딩 상태를 false로 되돌립니다.
            path.removeAll()
            isLoadingComplete = false
            // LoadingView의 onAppear 로직에 따라 일정 시간 후 isLoadingComplete가 true로 바뀌고,
            // users 쿼리가 빈 상태이므로 LoginView가 표시될 것입니다.
        }
}

@main
struct CM_ProjectApp: App {
    
    var body: some Scene {
        WindowGroup {
            AppView()
        }
        .modelContainer(for: User.self)
        
    }
}
