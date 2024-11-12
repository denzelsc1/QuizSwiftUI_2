//
//  practica4App.swift
//  practica4
//
//  Created by d068 DIT UPM on 6/11/24.
//

import SwiftUI

@main
struct practica4App: App {
    @State var quizzesModel = QuizzesModel()
    var body: some Scene {
        WindowGroup {
            QuizListView()
                .environment(quizzesModel)
        }
    }
}
