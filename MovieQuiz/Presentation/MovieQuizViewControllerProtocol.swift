import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: UIViewController {
    func showQuestion(quiz step: QuizStepViewModel)
    func showResults(resultsViewModel: QuizResultsViewModel)
    func setImageBorder(answerWasCorrect: Bool)
    func showLoadingIndicator()
    func toggleAnswerButtons()
    func startNewRound()
}
