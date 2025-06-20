//
//  LoadingView.swift
//  Space S
//
//  Created by 김재현 on 5/10/25.
//

import SwiftUI

struct LoadingView: View {
    //@Binding var path: [Route]
    @State private var progress: Double = 0.0
    @Binding var isLoadingComplete: Bool
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
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
            .alert("API Error", isPresented: $showErrorAlert) {
                Button("OK") {
                    isLoadingComplete = true
                }
            } message: {
                Text(errorMessage)
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

        checkStatus1 { success in checkFinished(success: success) }
        checkAPI1 { success in checkFinished(success: success) }
        checkAPI2 { success in checkFinished(success: success) }
    }

    func checkStatus1(completion: @escaping (Bool) -> Void) {
        LaunchDateGenerator.generateAndSaveUpcomingLaunchDates { success in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(success)
            }
        }
    }

    func checkAPI1(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(true) // 또는 실제 로직에 따라 true/false
        }
    }

    func checkAPI2(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion(true) // 또는 실제 로직에 따라 true/false
        }
    }
}

//#Preview {
//    @Previewable @State var previewPath: [Route] = []
//    LoadingViewPreviewWrapper(path: previewPath)
//}
//
//private struct LoadingViewPreviewWrapper: View {
//    @State private var isLoadingComplete = false
//    
//    var body: some View {
//        LoadingView(path: $path, isLoadingComplete: $isLoadingComplete)
//    }
//}
