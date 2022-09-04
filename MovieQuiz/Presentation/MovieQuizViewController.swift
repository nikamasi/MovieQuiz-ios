import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var currentQuestionIndex = 0
    private var score = 0
    private let dateFormatter = DateFormatter()
    private let dateFormat = "dd.MM.yy HH:mm"
    private var statisticService: StatisticService?
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.isEnabled = false
        yesButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        dateFormatter.dateFormat = dateFormat
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        handleButtonClick(answerWasCorrect: currentQuestion.answer == true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        handleButtonClick(answerWasCorrect: currentQuestion.answer == false)
    }

    // MARK: - Private functions

    private func showNetworkError(message: String) {
        let alert = UIAlertController(title: "Ошибка соединения", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    private func handleButtonClick(answerWasCorrect: Bool) {
        toggleAnswerButtons()
        if answerWasCorrect {
            score += 1
        }
        setImageBorder(answerWasCorrect: answerWasCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.questionText
        counterLabel.text = step.questionNumber
    }

    private func toggleAnswerButtons() {
        noButton.isEnabled.toggle()
        yesButton.isEnabled.toggle()
    }

    private func setImageBorder(answerWasCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor(named: answerWasCorrect ? "YP Green" : "YP Red")?.cgColor
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex < questionsAmount - 1 {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0
            questionFactory?.requestNextQuestion()
        } else {
            statisticService?.store(correct: score, total: questionsAmount)
            let title = score == questionsAmount ? "Поздравляем!" : "Этот раунд окончен!"
            guard let stats = statisticService else {
                return
            }
            let correct = stats.bestGame.correct
            let totalQuestions = stats.bestGame.total
            let dateString = dateFormatter.string(from: stats.bestGame.date)
            let message = """
                Ваш результат: \(score)/\(questionsAmount)
                Количество сыгранных квизов: \(stats.gamesCount)
                Рекорд: \(correct)/\(totalQuestions) (\(dateString))
                Средняя точность: \(String(format: "%.2f", stats.totalAccuracy))%
                """
            let resultsViewModel = QuizResultsViewModel(
                title: title,
                text: message,
                buttonText: "Сыграть еще раз")
            let resultAlertPresenter = ResultAlertPresenter()
            resultAlertPresenter.showResults(quiz: resultsViewModel, alertPresenter: self) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.startNewRound()
            }
        }
    }

    private func startNewRound() {
        imageView.layer.borderWidth = 0
        currentQuestionIndex = 0
        score = 0
        questionFactory?.requestNextQuestion()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        let step = QuizStepViewModel(
            image: image,
            questionText: model.question,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return step
    }

    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.showQuestion(quiz: viewModel)
            self?.toggleAnswerButtons()
        }
    }
}
