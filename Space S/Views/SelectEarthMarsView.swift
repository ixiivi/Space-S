//
//  Untitled.swift
//  Space S
//
//  Created by 김재현 on 5/11/25.
//

import SwiftUI

struct SelectEarthMarsView: View {
    let model: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("Select Destination")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Where will your Optimus \(model) be deployed?")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // 지구 선택 버튼
                Button(action: {
                    Logger.logInfo("Earth selected for Optimus \(model)")
                    // TODO: 지구 선택 처리
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        Text("Earth")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("Support Earth's AI infrastructure")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 32)
                
                // 화성 선택 버튼
                Button(action: {
                    Logger.logInfo("Mars selected for Optimus \(model)")
                    // TODO: 화성 선택 처리
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("Mars")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("Build Mars' AI civilization")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 32)
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Select Destination")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SelectEarthMarsView(model: "Gen6")
    }
}
