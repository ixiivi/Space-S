//
//  MarsSideView.swift
//  Space S
//
//  Created by 김재현 on 5/29/25.
//

import SwiftUI
import SwiftData

struct MarsSideView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User
    @Binding var path: [Route]
    
    init(path: Binding<[Route]>, user: User) {
        self._path = path
        self.user = user
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.red)
                Text("Mars")
                    .foregroundColor(.gray)
            }
            .padding()
            .onAppear{
                MarsSideTest()
            }
        }
    }
}

func MarsSideTest(){
    Logger.logInfo("App started successfully.")
}
