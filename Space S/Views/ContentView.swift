//
//  ContentView.swift
//  Space S
//
//  Created by 김재현 on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear{
            LogTest()
        }
    }
}

func LogTest(){
    Logger.logInfo("App started successfully.")
}


#Preview {
    ContentView()
}
