//
//  LoginView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//
//
//  LoginView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//


import SwiftUI

// Route enum: buyBot과 order 경로 정의
enum Route: Hashable {
    case buyBot
    case order(model: String) // 주문 화면으로 이동
}

struct LoginView: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 5)
                    
                    // 상단: 로고와 텍스트
                    HStack(alignment: .bottom) {
                        Image("logo") // 로고 이미지 추가 필요
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)

                        Spacer()

                        Text("Launch Now.")
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .baselineOffset(6)
                    }
                    .padding(.horizontal, 32)
                    
                    // 버튼들
                    VStack(spacing: 10) {
                        // 구글 로그인 버튼 (임시: Firebase 인증 생략)
                        Button(action: {
                            Logger.logInfo("Navigating to BuyBotMainView")
                            path.append(.buyBot)
                        }) {
                            HStack {
                                Image("google logo") // 구글 로고 이미지 필요
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text("Continue with Google")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        }

                        // 애플 로그인 버튼
                        Button(action: {
                            Logger.logInfo("Apple Sign-In tapped")
                            // 애플 로그인 로직 (미구현)
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Continue with Apple")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        }

                        // 구분선
                        Text("- or -")
                            .foregroundColor(.gray)
                            .font(.caption)

                        // 계정 만들기
                        Button(action: {
                            Logger.logInfo("Create account tapped")
                            // 회원가입 로직 (미구현)
                        }) {
                            Text("Create account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }

                        // 이미 가입 문구 + 로그인 버튼
                        VStack(spacing: 8) {
                            Text("Already have an account?")
                                .foregroundColor(.gray)
                                .font(.footnote)

                            Button(action: {
                                Logger.logInfo("Sign in tapped")
                                // 로그인 로직 (미구현)
                            }) {
                                Text("Sign in")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 999)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .preferredColorScheme(.dark)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .buyBot:
                    BuyBotMainView(path: $path) // path 바인딩 전달
                case .order(let model):
                    BuyBotOrderView(model: model) // 주문 화면
                }
            }
        }
    }
}

#Preview {
    LoginView()
}


//
//import SwiftUI
////
//// Route enum: buyBot과 order 경로 정의
//public enum Route: Hashable {
//    case buyBot
//    case slect(model: String) // 지구 화성 선택 화면으로 이동
//    case order(model: String)
//    //case confirmation(order: )
//}
//
//struct LoginView: View {
//    @State private var path: [Route] = []
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            ZStack {
//                Color.black.ignoresSafeArea()
//                
//                VStack(spacing: 32) {
//                    Spacer()
//                        .frame(height: UIScreen.main.bounds.height / 5)
//                    
//                    // 상단: 로고와 텍스트
//                    HStack(alignment: .bottom) {
//                        Image("logo") // 로고 이미지 추가 필요
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 100, height: 100)
//
//                        Spacer()
//
//                        Text("Launch Now.")
//                            .foregroundColor(.white)
//                            .font(.system(size: 28, weight: .bold))
//                            .baselineOffset(6)
//                    }
//                    .padding(.horizontal, 32)
//                    
//                    // 버튼들
//                    VStack(spacing: 10) {
//                        // 구글 로그인 버튼 (임시: Firebase 인증 생략)
//                        Button(action: {
//                            Logger.logInfo("Navigating to BuyBotMainView")
//                            path.append(.buyBot)
//                        }) {
//                            HStack {
//                                Image("google logo") // 구글 로고 이미지 필요
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 18, height: 18)
//                                Text("Continue with Google")
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.white)
//                            .foregroundColor(.black)
//                            .clipShape(Capsule())
//                        }
//
//                        // 애플 로그인 버튼
//                        Button(action: {
//                            Logger.logInfo("Apple Sign-In tapped")
//                            // 애플 로그인 로직 (미구현)
//                        }) {
//                            HStack {
//                                Image(systemName: "applelogo")
//                                Text("Continue with Apple")
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.white)
//                            .foregroundColor(.black)
//                            .clipShape(Capsule())
//                        }
//
//                        // 구분선
//                        Text("- or -")
//                            .foregroundColor(.gray)
//                            .font(.caption)
//
//                        // 계정 만들기
//                        Button(action: {
//                            Logger.logInfo("Create account tapped")
//                            // 회원가입 로직 (미구현)
//                        }) {
//                            Text("Create account")
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.accentColor)
//                                .foregroundColor(.white)
//                                .clipShape(Capsule())
//                        }
//
//                        // 이미 가입 문구 + 로그인 버튼
//                        VStack(spacing: 8) {
//                            Text("Already have an account?")
//                                .foregroundColor(.gray)
//                                .font(.footnote)
//
//                            Button(action: {
//                                Logger.logInfo("Sign in tapped")
//                                // 로그인 로직 (미구현)
//                            }) {
//                                Text("Sign in")
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(Color.black)
//                                    .foregroundColor(.white)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 999)
//                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
//                                    )
//                                    .clipShape(Capsule())
//                            }
//                        }
//                        .padding(.top, 8)
//                    }
//                    .padding(.horizontal, 32)
//                    
//                    Spacer()
//                }
//            }
//            .preferredColorScheme(.dark)
//            .navigationBarBackButtonHidden(true)
//            .navigationDestination(for: Route.self) { route in
//                switch route {
//                case .buyBot:
//                    BuyBotMainView(path: $path) // path 바인딩 전달
//                case .order(let model):
//                    BuyBotOrderView(model: model) // 주문 화면
//                case .slect(model: let model):
//                    SelectEarthMarsView(model: model)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    if let specs = BotSpec.loadSpecs(), let botSpec = specs["Gen6"] {
//        LoginView()
//            .environmentObject(RobotOrder(bot_spec: botSpec))
//            .environmentObject(User(id: "test123", name: "Test User", email: "test@example.com"))
//    } else {
//        LoginView()
//            .environmentObject(User(id: "test123", name: "Test User", email: "test@example.com"))
//    }
//}

//#Preview {
//    LoginView()
//}

//-----------------
//import SwiftUI
//import GoogleSignIn
//import FirebaseAuth
//
//struct LoginView: View {
//    @StateObject private var bot = RobotOrder(model: "Gen6")
//    @StateObject private var user = User(id: "temp", name: "Temp User", email: "temp@example.com")
//    @State private var path = NavigationPath()
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 32) {
//                Text("Welcome to Space S")
//                    .font(.system(size: 36, weight: .bold))
//                    .foregroundColor(.white)
//                
//                Button(action: {
//                    handleSignIn()
//                }) {
//                    Text("Continue with Google")
//                        .font(.system(size: 18, weight: .bold))
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                .padding(.horizontal, 32)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black)
//            .preferredColorScheme(.dark)
//            .navigationDestination(for: Route.self) { route in
//                switch route {
//                case .buyBot:
//                    BuyBotMainView(path: $path)
//                        .environmentObject(bot)
//                        .environmentObject(user)
//                case .order(let model):
//                    BuyBotOrderView(model: model)
//                        .environmentObject(bot)
//                        .environmentObject(user)
//                case .confirmation(let order):
//                    OrderConfirmationView(order: order)
//                        .environmentObject(bot)
//                        .environmentObject(user)
//                }
//            }
//        }
//    }
//
//    private func handleSignIn() {
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//        let config = GIDConfiguration(clientID: clientID)
//        
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: UIApplication.shared.windows.first?.rootViewController) { googleUser, error in
//            if let error = error {
//                Logger.logError("Google Sign-In failed: \(error)")
//                return
//            }
//            guard let googleUser = googleUser else { return }
//            user.id = googleUser.userID ?? UUID().uuidString
//            user.name = googleUser.profile?.name ?? "Unknown"
//            user.email = googleUser.profile?.email ?? "unknown@example.com"
//            Logger.logInfo("User signed in: \(user.id)")
//            path.append(Route.buyBot)
//        }
//    }
//}
//
//struct OrderConfirmationView: View {
//    let order: RobotOrder
//
//    var body: some View {
//        VStack {
//            Text("Order Confirmed!")
//                .font(.title)
//                .foregroundColor(.white)
//            Text("Optimus \(order.model) will arrive by \(order.newDelivery ?? order.estimatedDelivery).")
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black)
//        .preferredColorScheme(.dark)
//        .navigationTitle("Order Confirmation")
//    }
//}
//
//#Preview {
//    LoginView()
//        .environmentObject(RobotOrder(model: "Gen6"))
//        .environmentObject(User(id: "test123", name: "Test User", email: "test@example.com"))
//}

//------------------
//import SwiftUI
//
//struct LoginView: View {
//    @StateObject private var bot = RobotOrder(model: "Gen6")
//    @StateObject private var user = User(id: "temp", name: "Temp User", email: "temp@example.com")
//    @State private var path = NavigationPath()
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 32) {
//                Text("Welcome to Space S")
//                    .font(.system(size: 36, weight: .bold))
//                    .foregroundColor(.white)
//                
//                Button(action: {
//                    // Simulate login with mock user data
//                    user.id = "user123"
//                    user.name = "John Doe"
//                    user.email = "john@example.com"
//                    Logger.logInfo("User logged in: \(user.id)")
//                    path.append(Route.buyBot)
//                }) {
//                    Text("Login")
//                        .font(.system(size: 18, weight: .bold))
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                .padding(.horizontal, 32)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black)
//            .preferredColorScheme(.dark)
//            .navigationDestination(for: Route.self) { route in
//                switch route {
//                case .buyBot:
//                    BuyBotMainView(path: $path)
//                        .environmentObject(bot)
//                        .environmentObject(user)
//                case .order(let model):
//                    BuyBotOrderView(model: model)
//                        .environmentObject(bot)
//                        .environmentObject(user)
////                case .confirmation(let order):
////                    OrderConfirmationView(order: order)
////                        .environmentObject(bot)
////                        .environmentObject(user)
//                case .slect(: let model):
//                    SelectEarthMarsView()
//                    <#code#>
//                }
//            }
//        }
//    }
//}
//
//struct OrderConfirmationView: View {
//    let order: RobotOrder
//
//    var body: some View {
//        VStack {
//            Text("Order Confirmed!")
//                .font(.title)
//                .foregroundColor(.white)
//            Text("Optimus \(order.model) will arrive by \(order.newDelivery ?? order.estimatedDelivery).")
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black)
//        .preferredColorScheme(.dark)
//        .navigationTitle("Order Confirmation")
//    }
//}
//
//#Preview {
//    LoginView()
//        .environmentObject(RobotOrder(model: "Gen6"))
//        .environmentObject(User(id: "test123", name: "Test User", email: "test@example.com"))
//}
