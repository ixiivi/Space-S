//
//  LoadingView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var progress: Double = 0.0
    @Binding var isLoadingComplete: Bool
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Image("LoadingView_background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Spacer()
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(width: min(geometry.size.width * 0.5, 200))

                        Spacer()
                            .frame(height: geometry.size.height * 0.1)
                    }
                    .padding(.horizontal)
                }
            }
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
            .onAppear {
                runAllAPIChecks()
            }
            .navigationDestination(isPresented: $isLoadingComplete) {
                LoginView()
            }
            .alert("API Error", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    func runAllAPIChecks() {
        let totalAPIs = 3
        var successfulCompletions = 0
        var completed = 0
        var allSuccessful = true

        func checkFinished(success: Bool, error: String? = nil) {
            completed += 1
            
            if success {
                successfulCompletions += 1
            } else {
                allSuccessful = false
                if let error = error {
                    errorMessage = error
                }
            }

            withAnimation {
                progress = Double(successfulCompletions) / Double(totalAPIs)
            }

            if completed == totalAPIs {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if allSuccessful {
                        isLoadingComplete = true
                    } else {
                        showErrorAlert = true
                    }
                }
            }
        }

        checkAPI1 { checkFinished(success: true) }
        checkAPI2 { checkFinished(success: true) }
        checkAPI3 { checkFinished(success: true) }
    }

    func checkAPI1(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: completion)
    }

    func checkAPI2(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: completion)
    }

    func checkAPI3(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: completion)
    }
}

#Preview {
    LoadingViewPreviewWrapper()
}

private struct LoadingViewPreviewWrapper: View {
    @State private var isLoadingComplete = false

    var body: some View {
        LoadingView(isLoadingComplete: $isLoadingComplete)
    }
}
