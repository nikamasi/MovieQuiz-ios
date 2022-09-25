import Foundation
import UIKit


class QuestionFactory: QuestionFactoryProtocol {
    private let delegate: QuestionFactoryDelegate
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    enum QuestionFactoryError: Error {
        case noMovies(message: String)
        case apiError(message: String)
    }

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            let rating = Float(movie.rating) ?? 0
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch let error {
                print("Failed to load image")
                self.delegate.didFailToLoadData(with: error)
                return
            }
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(
                image: imageData,
                rating: rating,
                question: text,
                answer: correctAnswer)
            self.delegate.didReceiveNextQuestion(question: question)
        }
    }
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                if !movies.errorMessage.isEmpty {
                    self.delegate.didFailToLoadData(
                        with: QuestionFactoryError.apiError(message: movies.errorMessage)
                    )
                } else if movies.items.isEmpty {
                    self.delegate.didFailToLoadData(
                        with: QuestionFactoryError.noMovies(message: "No movies loaded.")
                    )
                } else {
                    var moviesWithRating: [MostPopularMovie] = []
                    for movie in movies.items {
                        let rating = Float(movie.rating) ?? 0
                        if rating != 0 {
                            moviesWithRating.append(movie)
                        }
                    }
                    if moviesWithRating.isEmpty {
                        self.delegate.didFailToLoadData(
                            with: QuestionFactoryError.noMovies(message: "Coldn't load movies with a rating.")
                        )
                    } else {
                        self.movies = moviesWithRating
                        self.delegate.didLoadDataFromServer()
                    }
                }
            case .failure(let error):
                self.delegate.didFailToLoadData(with: error)
            }
        }
    }
// MARK: - Mock Data
//
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: UIImage(named: "The Godfather"),
//            rating: 9.2,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: true),
//        QuizQuestion(
//            image: UIImage(named: "The Dark Knight"),
//            rating: 9,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: true),
//        QuizQuestion(
//            image: UIImage(named: "Kill Bill"),
//            rating: 9.2,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: true),
//        QuizQuestion(
//            image: UIImage(named: "The Avengers"),
//            rating: 8,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: true),
//        QuizQuestion(
//            image: UIImage(named: "Deadpool"),
//            rating: 8,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: true),
//        QuizQuestion(
//            image: UIImage(named: "The Green Knight"),
//            rating: 6.6,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: true),
//        QuizQuestion(
//            image: UIImage(named: "Old"),
//            rating: 5.8,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: false),
//        QuizQuestion(
//            image: UIImage(named: "The Ice Age Adventures of Buck Wild"),
//            rating: 4.3,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: false),
//        QuizQuestion(
//            image: UIImage(named: "Tesla"),
//            rating: 5.1,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: false),
//        QuizQuestion(
//            image: UIImage(named: "Vivarium"),
//            rating: 5.8,
//            question: "Рейтинг этого фильма больше чем 6?",
//            answer: false)
//    ]
}
