//
//  CM_term_projectApp.swift
//  CM term project
//
//  Created by 김재현 on 5/2/25.
//

import SwiftUI

struct AppView: View {
    @State private var isLoadingComplete = false
    
    var body: some View {
        if isLoadingComplete {
            LoginView()
        } else {
            LoadingView(isLoadingComplete: $isLoadingComplete)
        }
    }
}

@main
struct CM_ProjectApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
