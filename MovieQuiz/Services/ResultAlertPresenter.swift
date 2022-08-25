import Foundation
import UIKit

class ResultAlertPresenter {
    func showResults(quiz step: QuizResultsViewModel, alertPresenter: UIViewController, onAction: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(
            title: step.title,
            message: step.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: step.buttonText, style: .default, handler: onAction)
        alert.addAction(action)
        alertPresenter.present(alert, animated: true, completion: nil)
    }
}
