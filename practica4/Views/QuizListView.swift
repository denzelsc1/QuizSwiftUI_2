import SwiftUI

struct QuizListView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(QuizzesModel.self) var quizzesModel
    @State private var hasLoaded = false // Variable para verificar si se han cargado los quizzes
    @State private var showUnansweredOnly = false // Variable para controlar el Toggle
    @State private var showCorrectOnly = false // Variable para controlar el Toggle de mostrar solo quizzes acertados
    @State private var answeredQuizIds: Set<Int> = [] // Almacena los IDs de los quizzes acertados
    @State private var totalCorrectAnswers: Int = UserDefaults.standard.integer(forKey: "totalCorrectAnswers") // Recuperar desde UserDefaults

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Título grande en la parte superior
                Text("Quizzes")
                    .font(.system(size: 34, weight: .bold)) // Escalable
                    .padding(.leading)
                    .foregroundColor(.blue)

                // Apartado de "Quizzes acertados" con imagen de tick dentro de un bloque verde
                
                if verticalSizeClass == .compact { // En modo horizontal, dividir en 2 columnas
                    HStack {
                        // Columna izquierda para los datos
                        VStack {
                            // Apartado de "Quizzes acertados" con imagen de tick dentro de un bloque verde
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Quizzes acertados")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .bold()
                                    Text("\(answeredQuizIds.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(15)
                            .shadow(radius: 4)
                            .padding([.top, .horizontal])
                            
                            // Apartado de "Total acertados" con imagen de estrella fuera del bloque verde
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total acertados")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .bold()
                                    Text("\(totalCorrectAnswers)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(15)
                            .shadow(radius: 4)
                            .padding([.top, .horizontal])
                            
                            // Toggle para mostrar solo los quizzes acertados
                            HStack {
                                Text("Mostrar solo quizzes acertados")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                                Toggle("", isOn: $showCorrectOnly)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Columna derecha para la lista de quizzes
                        VStack {
                            // Lista de quizzes
                            List {
                                ForEach(filteredQuizzes()) { quiz in
                                    NavigationLink(destination: QuizjugarView(quiz: quiz, onQuizAnswered: { isCorrect in
                                        if isCorrect {
                                            handleCorrectAnswer(for: quiz.id)
                                        }
                                    })) {
                                        HStack(alignment: .center, spacing: 15) {
                                            // Imagen adjunta del quiz en forma circular
                                            if let url = quiz.attachment?.url {
                                                AsyncImage(url: url) { image in
                                                    image.resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60, height: 60)
                                                    .foregroundColor(.gray)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                            }

                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(quiz.question)
                                                    .font(.headline)
                                                    .foregroundColor(.blue)
                                                    .multilineTextAlignment(.leading)
                                                    .lineLimit(2)
                                                    .padding(8)
                                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.1)))

                                                HStack(spacing: 12) {
                                                    // Foto del autor
                                                    if let authorPhotoURL = quiz.author?.photo?.url {
                                                        AsyncImage(url: authorPhotoURL) { phase in
                                                            switch phase {
                                                            case .empty:
                                                                ProgressView()
                                                            case .success(let image):
                                                                image.resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 30, height: 30)
                                                                    .clipShape(Circle())
                                                                    .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                                                            case .failure:
                                                                Image(systemName: "person.crop.circle.fill")
                                                                    .resizable()
                                                                    .frame(width: 30, height: 30)
                                                                    .foregroundColor(.gray)
                                                            @unknown default:
                                                                EmptyView()
                                                            }
                                                        }
                                                    } else {
                                                        Image(systemName: "person.crop.circle.fill")
                                                            .resizable()
                                                            .frame(width: 30, height: 30)
                                                            .foregroundColor(.gray)
                                                    }
                                                    
                                                    Text(quiz.author?.profileName ?? "Desconocido")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: quiz.favourite ? "star.fill" : "star")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    quizzesModel.toggleFavourite(quizId: quiz.id, isFavourite: quiz.favourite) { success in
                                                        if !success {
                                                            print("No se pudo actualizar el estado favorito del quiz con id \(quiz.id)")
                                                        }
                                                    }
                                                }
                                                .animation(.easeInOut, value: quiz.favourite)
                                        }
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.05)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15).stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                        )
                                        .shadow(color: Color.blue.opacity(0.2), radius: 5, x: 0, y: 3)
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                } else { // En modo vertical
                    VStack {
                        // Apartado de "Quizzes acertados" con imagen de tick dentro de un bloque verde
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Quizzes acertados")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .bold()
                                Text("\(answeredQuizIds.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(15)
                        .shadow(radius: 4)
                        .padding([.top, .horizontal])
                        
                        // Apartado de "Total acertados" con imagen de estrella fuera del bloque verde
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total acertados")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .bold()
                                Text("\(totalCorrectAnswers)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(15)
                        .shadow(radius: 4)
                        .padding([.top, .horizontal])

                        // Toggle para mostrar solo los quizzes acertados
                        HStack {
                            Text("Mostrar solo quizzes acertados")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Spacer()
                            Toggle("", isOn: $showCorrectOnly)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }

                    // Lista de quizzes
                    List {
                        ForEach(filteredQuizzes()) { quiz in
                            NavigationLink(destination: QuizjugarView(quiz: quiz, onQuizAnswered: { isCorrect in
                                if isCorrect {
                                    handleCorrectAnswer(for: quiz.id)
                                }
                            })) {
                                HStack(alignment: .center, spacing: 15) {
                                    // Imagen adjunta del quiz en forma circular
                                    if let url = quiz.attachment?.url {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.gray)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(quiz.question)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .padding(8)
                                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.1)))

                                        HStack(spacing: 12) {
                                            // Foto del autor
                                            if let authorPhotoURL = quiz.author?.photo?.url {
                                                AsyncImage(url: authorPhotoURL) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                    case .success(let image):
                                                        image.resizable()
                                                            .scaledToFit()
                                                            .frame(width: 30, height: 30)
                                                            .clipShape(Circle())
                                                            .overlay(Circle().stroke(Color.blue, lineWidth: 1))
                                                    case .failure:
                                                        Image(systemName: "person.crop.circle.fill")
                                                            .resizable()
                                                            .frame(width: 30, height: 30)
                                                            .foregroundColor(.gray)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            } else {
                                                Image(systemName: "person.crop.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Text(quiz.author?.profileName ?? "Desconocido")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: quiz.favourite ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            quizzesModel.toggleFavourite(quizId: quiz.id, isFavourite: quiz.favourite) { success in
                                                if !success {
                                                    print("No se pudo actualizar el estado favorito del quiz con id \(quiz.id)")
                                                }
                                            }
                                        }
                                        .animation(.easeInOut, value: quiz.favourite)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.05)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15).stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                )
                                .shadow(color: Color.blue.opacity(0.2), radius: 5, x: 0, y: 3)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]), startPoint: .top, endPoint: .bottom))
            .onAppear {
                if !hasLoaded {
                    quizzesModel.load() // Cargar quizzes solo si no se han cargado previamente
                    hasLoaded = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        quizzesModel.load() // Recargar quizzes al presionar el botón
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Recargar quizzes")
                }
            }
        }
    }
    
    private func handleCorrectAnswer(for quizId: Int) {
        if !answeredQuizIds.contains(quizId) {
            answeredQuizIds.insert(quizId)
            totalCorrectAnswers += 1
            UserDefaults.standard.set(totalCorrectAnswers, forKey: "totalCorrectAnswers")
        }
    }
    
    // Función que filtra los quizzes según el estado del Toggle
    private func filteredQuizzes() -> [QuizItem] {
        if showUnansweredOnly {
            return quizzesModel.quizzes.filter { quiz in
                !answeredQuizIds.contains(quiz.id)
            }
        } else if showCorrectOnly {
            return quizzesModel.quizzes.filter { quiz in
                answeredQuizIds.contains(quiz.id)
            }
        } else {
            return quizzesModel.quizzes
        }
    }
}

