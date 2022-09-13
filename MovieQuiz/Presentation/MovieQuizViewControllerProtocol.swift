import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: UIViewController {
    func showQuestion(quiz step: QuizStepViewModel)
    func setImageBorder(answerWasCorrect: Bool)
    func showLoadingIndicator()
    func toggleAnswerButtons()
    func startNewRound()
}
