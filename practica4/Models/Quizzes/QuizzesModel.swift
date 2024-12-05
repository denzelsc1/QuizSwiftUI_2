//
//  QuizzesModel.swift
//  Quiz
//
//  Created by Santiago Pavón Gómez on 18/10/24.
//
import Foundation

/// Errores producidos en el modelo de los Quizzes
enum QuizzesModelError: LocalizedError {
    case internalError(msg: String)
    case corruptedDataError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .internalError(let msg):
            return "Error interno: \(msg)"
        case .corruptedDataError:
            return "Recibidos datos corruptos"
        case .unknownError:
            return "Error desconocido"
       }
    }
}

@Observable class QuizzesModel {
    
    // Los datos
    private(set) var quizzes = [QuizItem]()
    private(set) var contador: Set<String> = Set()
    private let apiURLString = "https://quiz.dit.upm.es/api/quizzes/random10?token=cd2554928eddddeb5a0b"

    func load() {
        guard let apiURL = URL(string: apiURLString) else {
            print("URL inválida")
            return
        }

        let task = URLSession.shared.dataTask(with: apiURL) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error en la solicitud: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Respuesta HTTP no válida")
                return
            }

            guard let data = data else {
                print("No se recibieron datos")
                return
            }

            do {
                let quizzes = try JSONDecoder().decode([QuizItem].self, from: data)
                DispatchQueue.main.async {
                    // Reiniciar el contador antes de asignar los nuevos quizzes
                    self.contador = Set()
                    self.quizzes = quizzes
                    print("Quizzes cargados desde la API")
                }
            } catch {
                print("Error al decodificar los datos: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    func checkAnswer(quizId: Int, answer: String, completion: @escaping (Bool) -> Void) {
        guard let apiURL = URL(string: "https://quiz.dit.upm.es/api/quizzes/\(quizId)/check?answer=\(answer)&token=cd2554928eddddeb5a0b") else {
            print("URL inválida")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let error = error {
                print("Error en la solicitud: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Respuesta HTTP no válida")
                completion(false)
                return
            }

            guard let data = data else {
                print("No se recibieron datos")
                completion(false)
                return
            }

            do {
                let result = try JSONDecoder().decode(QuizItem.Answer.self, from: data)
                DispatchQueue.main.async {
                    if result.result == true {
                        // Agregar el ID del quiz a `contador` si la respuesta es correcta
                        self.contador.insert("\(quizId)")
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } catch {
                print("Error al decodificar los datos: \(error.localizedDescription)")
                completion(false)
            }
        }

        task.resume()
    }

    func addCorrectAnswer(quizId: String) {
        contador.insert(quizId)
    }
}
