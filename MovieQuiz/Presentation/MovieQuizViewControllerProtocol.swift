import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: UIViewController {
    func showQuestion(quiz step: QuizStepViewModel)
    func showResults(resultsViewModel: QuizResultsViewModel)
    func showError(message: String, title: String, buttonText: String, onAction: @escaping (UIAlertAction) -> Void)
    func setImageBorder(answerWasCorrect: Bool)
    func showLoadingIndicator()
    func toggleAnswerButtons()
    func startNewRound()
}
