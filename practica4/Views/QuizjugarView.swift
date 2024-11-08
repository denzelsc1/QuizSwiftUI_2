//
//  QuizjugarView.swift
//  practica4
//
//  Created by d068 DIT UPM on 8/11/24.
//
import SwiftUI

struct QuizjugarView: View {
    let quiz: QuizItem
    @State private var userAnswer: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Para controlar la navegación
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var quizzesModel: QuizzesModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Título de la pregunta
            Text(quiz.question)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            // Mostrar la imagen adjunta del quiz (si tiene)
            if let imageURL = quiz.attachment?.url {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    case .success(let image):
                        image.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .foregroundColor(.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Estrella para indicar si el quiz es favorito
            HStack {
                Text(quiz.favourite ? "⭐️" : "☆")
                    .font(.title)
                    .foregroundColor(.yellow)
                Spacer() // Empuja el contenido a la izquierda
            }
            .padding(.horizontal)
            
            // Campo de texto para la respuesta del usuario
            TextField("Escribe tu respuesta", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical)
            
            // Botón para comprobar la respuesta
            Button("Comprobar respuesta") {
                checkAnswer()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            // HStack para la información del autor (alineado a la derecha)
            if let author = quiz.author {
                HStack {
                    VStack(alignment: .leading) {
                        if let authorImageURL = author.photo?.url {
                            AsyncImage(url: authorImageURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.gray)
                                        .clipShape(Circle())
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing) // Alineamos la foto y el nombre a la derecha
                    
                    VStack(alignment: .trailing) {
                        Text(author.profileName ?? "Desconocido")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text(author.username ?? "Sin nombre de usuario")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing) // Alineamos el texto a la derecha
                }
                .padding(.top)
            }
            
            // Botón para volver a la lista de quizzes (en la parte inferior)
            Button("Volver") {
                presentationMode.wrappedValue.dismiss() // Volver a la pantalla anterior
            }
            .padding()
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Responder Quiz")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Resultado"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func checkAnswer() {
        // Verifica si la respuesta es correcta
        if userAnswer.lowercased() == quiz.answer.lowercased() {
            alertMessage = "¡Correcto!"
            
            // Convierte quiz.id (que es un Int) a String antes de pasarlo a addCorrectAnswer
            quizzesModel.addCorrectAnswer(quizId: String(quiz.id))
        } else {
            alertMessage = "Incorrecto, inténtalo de nuevo."
        }
        showAlert = true
    }

}
