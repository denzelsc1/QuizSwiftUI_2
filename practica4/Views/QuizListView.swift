//
//  QuizListView.swift
//  practica4
//
//  Created by d068 DIT UPM on 6/11/24.
//
import SwiftUI

struct QuizListView: View {
    
    @Environment(QuizzesModel.self) var quizzesModel

    var body: some View {
        NavigationStack {
            List(quizzesModel.quizzes) { quiz in
                    HStack {
                        // Muestra la pregunta
                        Text(quiz.question)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Muestra la imagen adjunta
                        if let url = quiz.attachment?.url {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                     .scaledToFit()
                                     .frame(width: 50, height: 50)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        
                        // Muestra la estrella de favorito
                        Image(systemName: quiz.favourite ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                        
                        // Muestra el nombre del autor
                        if let author = quiz.author {
                            Text(author.profileName ?? "Desconocido")
                        }
                    }
                }
            }
            .navigationTitle("Quizzes")
            .onAppear {
                quizzesModel.load()
            }
        }
    }

