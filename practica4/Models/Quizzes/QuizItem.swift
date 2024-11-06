//
//  QuizItem.swift
//  Quiz
//
//  Created by Santiago Pavón Gómez on 18/10/24.
//

import Foundation

struct QuizItem: Codable, Identifiable {
    let id: Int
    let question: String
    let answer: String
    let author: Author?
    let attachment: Attachment?
    let favourite: Bool
    
    struct Author: Codable {
        let isAdmin: Bool?
        let username: String?
        let profileName: String?
        let photo: Attachment?
    }
    
    struct Attachment: Codable {
        let filename: String?
        let mime: String?
        let url: URL?
    }
}
