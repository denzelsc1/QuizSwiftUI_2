import SwiftUI

struct QuizListView: View {
    
    // Usamos @EnvironmentObject para acceder al modelo global
    @EnvironmentObject var quizzesModel: QuizzesModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Título grande en la parte superior
                Text("Quizzes")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
                
                // Contador de quizzes acertados con un diseño más pequeño
                VStack {
                    Text("Quizzes acertados:")
                        .font(.subheadline) // Cambié el tamaño a subheadline
                        .foregroundColor(.gray) // Color más discreto
                    Text("\(quizzesModel.contador.count)")
                        .font(.title3) // Tamaño más pequeño para que no compita con el título
                        .fontWeight(.bold)
                        .foregroundColor(.green) // Color verde para resaltar el contador
                }
                .padding(10)
                .background(Color.white) // Fondo más suave
                .cornerRadius(10)
                .shadow(radius: 2) // Sombra más suave
                .padding([.top, .horizontal])
                
                // Lista de quizzes
                List {
                    ForEach(quizzesModel.quizzes) { quiz in
                        NavigationLink(destination: QuizjugarView(quiz: quiz)) { // Se va a la vista de jugar
                            HStack(alignment: .top, spacing: 15) {
                                // Muestra la imagen adjunta del quiz en forma circular
                                if let url = quiz.attachment?.url {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    // Muestra la pregunta del quiz
                                    Text(quiz.question)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        // Muestra la foto del autor en un círculo pequeño
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
                                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
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
                                        
                                        // Muestra el nombre del autor
                                        if let author = quiz.author {
                                            Text(author.profileName ?? "Desconocido")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            Spacer()
                            
                            // Muestra el icono de favorito como una estrella
                            Image(systemName: quiz.favourite ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("")
            .onAppear {
                quizzesModel.load()
            }
        }
    }
}


