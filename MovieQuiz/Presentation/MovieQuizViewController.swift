import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var presenter: MovieQuizPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.isEnabled = false
        yesButton.isEnabled = false
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    func showQuestion(quiz step: QuizStepViewModel) {
        activityIndicator.stopAnimating()
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.questionText
        counterLabel.text = step.questionNumber
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func toggleAnswerButtons() {
        noButton.isEnabled.toggle()
        yesButton.isEnabled.toggle()
    }

    func setImageBorder(answerWasCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor(named: answerWasCorrect ? "YP Green" : "YP Red")?.cgColor
    }

    func startNewRound() {
        activityIndicator.startAnimating()
        imageView.layer.borderWidth = 0
        presenter.restartGame()
    }
}
