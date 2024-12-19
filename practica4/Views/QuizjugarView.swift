import SwiftUI

struct QuizjugarView: View {
    let quiz: QuizItem
    @State private var userAnswer: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isScaled = false  // Para la animación de escala
    var onQuizAnswered: (Bool) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(QuizzesModel.self) var quizzesModel
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        VStack(spacing: 20) {
            if verticalSizeClass == .compact {
                // Vista en horizontal: dos columnas
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        // Columna izquierda: Imagen del quiz, pregunta y autor
                        VStack(alignment: .center, spacing: 10) {
                            if let imageURL = quiz.attachment?.url {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.2)))
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .onTapGesture(count: 2) {
                                                fetchAnswerAndAnimate()
                                            }
                                            .scaleEffect(isScaled ? 1.1 : 1.0)
                                            .animation(.easeInOut(duration: 0.3), value: isScaled)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }

                            // Pregunta
                            Text(quiz.question)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)  // Alineado al centro
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.1)))
                                .frame(maxWidth: .infinity, alignment: .center) // Centrado horizontalmente
                            
                            // Autor
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
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .padding(.top, 10)
                            }
                            Image(systemName: quiz.favourite ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding()
                                .scaleEffect(isScaled ? 1.1 : 1.0)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .animation(.easeInOut(duration: 0.3), value: isScaled)

                        }
                        .frame(width: geometry.size.width * 0.45) // Aseguramos que ocupe menos espacio

                        // Columna derecha: Botones y campo de respuesta
                        VStack(spacing: 10) {
                            // Respuesta del usuario
                            TextField("Escribe tu respuesta", text: $userAnswer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(5)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.05)))

                            // Botón para borrar respuesta
                            Button("Borrar respuesta") {
                                userAnswer = ""
                            }
                            .font(.footnote)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                            .foregroundColor(.red)

                            // Botón para mostrar respuesta correcta
                            Button("Mostrar respuesta correcta") {
                                quizzesModel.FetchAnswer(forQuizId: quiz.id) { correctAnswer in
                                    if let correctAnswer = correctAnswer {
                                        userAnswer = correctAnswer
                                    } else {
                                        alertMessage = "No se encontró la respuesta correcta."
                                        showAlert = true
                                    }
                                }
                            }
                            .font(.footnote)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                            .foregroundColor(.white)

                            // Botón para comprobar respuesta
                            Button("Comprobar respuesta") {
                                checkAnswer()
                            }
                            .font(.footnote)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                            .foregroundColor(.white)

                            Spacer()

                            // Botón para volver
                            Button("Volver") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .font(.footnote)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                        }
                        .frame(width: geometry.size.width * 0.45) // Aseguramos que ocupe menos espacio
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Vista en vertical: Mantenemos la vista original
                VStack {
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
                                    .onTapGesture(count: 2) {
                                        fetchAnswerAndAnimate()
                                    }
                                    .scaleEffect(isScaled ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: isScaled)
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
                    HStack{
                        // Imagen del autor y nombre del autor
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
                        HStack{
                            Image(systemName: quiz.favourite ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding()
                                .scaleEffect(isScaled ? 1.1 : 1.0)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .animation(.easeInOut(duration: 0.3), value: isScaled)
                        }
                    }
                    // Respuesta del usuario
                    TextField("Escribe tu respuesta", text: $userAnswer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.05)))

                    // Botón para borrar respuesta
                    Button("Borrar respuesta") {
                        userAnswer = ""
                    }
                    .font(.footnote)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                    .foregroundColor(.red)

                    // Botón para mostrar respuesta correcta
                    Button("Mostrar respuesta correcta") {
                        quizzesModel.FetchAnswer(forQuizId: quiz.id) { correctAnswer in
                            if let correctAnswer = correctAnswer {
                                userAnswer = correctAnswer
                            } else {
                                alertMessage = "No se encontró la respuesta correcta."
                                showAlert = true
                            }
                        }
                    }
                    .font(.footnote)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                    .foregroundColor(.white)

                    // Botón para comprobar respuesta
                    Button("Comprobar respuesta") {
                        checkAnswer()
                    }
                    .font(.footnote)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    .foregroundColor(.white)

                    Spacer()

                    // Botón para volver
                    Button("Volver") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.footnote)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
                .padding(.horizontal)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Resultado"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]), startPoint: .top, endPoint: .bottom))
    }
    
    private func fetchAnswerAndAnimate() {
        quizzesModel.FetchAnswer(forQuizId: quiz.id) { correctAnswer in
            if let correctAnswer = correctAnswer {
                userAnswer = correctAnswer
                withAnimation {
                    isScaled.toggle()
                }
            } else {
                alertMessage = "No se encontró la respuesta correcta."
                showAlert = true
            }
        }
    }
    
    private func checkAnswer() {
        quizzesModel.checkAnswer(quizId: quiz.id, answer: userAnswer) { isCorrect in
            if isCorrect {
                alertMessage = "¡Correcto!"
                quizzesModel.addCorrectAnswer(quizId: String(quiz.id))
                onQuizAnswered(true)
            } else {
                alertMessage = "Incorrecto, inténtalo de nuevo."
            }
            showAlert = true
        }
    }
}

