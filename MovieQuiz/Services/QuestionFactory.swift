import Foundation
import UIKit


class QuestionFactory: QuestionFactoryProtocol {
    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    private let delegate: QuestionFactoryDelegate
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: UIImage(named: "The Godfather"),
            rating: 9.2,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: true),
        QuizQuestion(
            image: UIImage(named: "The Dark Knight"),
            rating: 9,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: true),
        QuizQuestion(
            image: UIImage(named: "Kill Bill"),
            rating: 9.2,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: true),
        QuizQuestion(
            image: UIImage(named: "The Avengers"),
            rating: 8,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: true),
        QuizQuestion(
            image: UIImage(named: "Deadpool"),
            rating: 8,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: true),
        QuizQuestion(
            image: UIImage(named: "The Green Knight"),
            rating: 6.6,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: true),
        QuizQuestion(
            image: UIImage(named: "Old"),
            rating: 5.8,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: false),
        QuizQuestion(
            image: UIImage(named: "The Ice Age Adventures of Buck Wild"),
            rating: 4.3,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: false),
        QuizQuestion(
            image: UIImage(named: "Tesla"),
            rating: 5.1,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: false),
        QuizQuestion(
            image: UIImage(named: "Vivarium"),
            rating: 5.8,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: false)
    ]

    func requestNextQuestion() {
        let index = (0..<questions.count).randomElement() ?? 0
        self.delegate.didReceiveNextQuestion(question: questions[safe: index])
    }
}
