//
//  QuizItem.swift
//  Quiz
//
//  Created by Santiago Pavón Gómez on 18/10/24.
//

import Foundation

// Definimos la nueva estructura para `QuizItem`
struct QuizItem: Codable, Identifiable {
    let id: Int
    let question: String
    let answer: Answer?
    let author: Author?
    let attachment: Attachment?
    var favourite: Bool

    struct Author: Codable {
        let id: Int?
        let isAdmin: Bool?
        let username: String?
        let profileName: String?
        let photo: Attachment?
    }

    struct Attachment: Codable {
        let mime: String?
        let url: URL?
    }
    struct Answer: Codable {
        let quizId: Int?
        let answer: String?
        let result: Bool?
    }
}



