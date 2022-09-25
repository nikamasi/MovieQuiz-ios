import Foundation
import UIKit

class AlertPresenter {
    func showResults(quiz step: QuizResultsViewModel, alertPresenter: UIViewController, onAction: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(
            title: step.title,
            message: step.text,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "results"
        let action = UIAlertAction(title: step.buttonText, style: .default, handler: onAction)
        alert.addAction(action)
        alertPresenter.present(alert, animated: true, completion: nil)
    }

    func showError(message: String, title: String, buttonText: String, alertPresenter: UIViewController, onAction: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default, handler: nil)
        alert.addAction(action)
        alertPresenter.present(alert, animated: true, completion: nil)
    }
}
