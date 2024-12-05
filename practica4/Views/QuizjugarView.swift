import SwiftUI

struct QuizjugarView: View {
    let quiz: QuizItem
    @State private var userAnswer: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(QuizzesModel.self) var quizzesModel
    
    var body: some View {
        ScrollView { // Scroll para manejar el contenido en pantallas pequeñas
            VStack(spacing: 20) {
                Text(quiz.question)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.1)))
                    .padding(.horizontal)
                
                if let imageURL = quiz.attachment?.url {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.2)))
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                if let author = quiz.author {
                    HStack {
                        if let authorImageURL = author.photo?.url {
                            AsyncImage(url: authorImageURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().frame(width: 40, height: 40).clipShape(Circle())
                                case .success(let image):
                                    image.resizable().scaledToFit().frame(width: 40, height: 40).clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill").resizable().frame(width: 40, height: 40)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        Text(author.profileName ?? "Autor desconocido")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                TextField("Escribe tu respuesta", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.05)))
                    .padding(.horizontal)
                
                Button("Comprobar respuesta") {
                    checkAnswer()
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                .foregroundColor(.white)
                .padding(.horizontal)
                
                Spacer()
                
                Button("Volver") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                .padding(.horizontal)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Resultado"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]), startPoint: .top, endPoint: .bottom))
    }
    
    private func checkAnswer() {
        quizzesModel.checkAnswer(quizId: quiz.id, answer: userAnswer) { isCorrect in
            if isCorrect {
                alertMessage = "¡Correcto!"
                quizzesModel.addCorrectAnswer(quizId: String(quiz.id))
            } else {
                alertMessage = "Incorrecto, inténtalo de nuevo."
            }
            showAlert = true
        }
    }
}
