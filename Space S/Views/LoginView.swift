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
