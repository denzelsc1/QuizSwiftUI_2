//
//  ContentView.swift
//  practica4
//
//  Created by d068 DIT UPM on 6/11/24.
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
        .navigationTitle(Text("Quizzes"))
        .padding()
    }
}

#Preview {
    ContentView()
}
