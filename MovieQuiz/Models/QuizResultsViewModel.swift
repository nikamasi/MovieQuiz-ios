import Foundation
import UIKit

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
    init(title: String, buttonText: String, stats: StatisticService, questionsAmount: Int, score: Int) {
        let correct = stats.bestGame.correct
        let totalQuestions = stats.bestGame.total
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        let dateString = dateFormatter.string(from: stats.bestGame.date)
        self.text = """
            Ваш результат: \(score)/\(questionsAmount)
            Количество сыгранных квизов: \(stats.gamesCount)
            Рекорд: \(correct)/\(totalQuestions) (\(dateString))
            Средняя точность: \(String(format: "%.2f", stats.totalAccuracy))%
            """
        self.title = title
        self.buttonText = buttonText
    }
}
