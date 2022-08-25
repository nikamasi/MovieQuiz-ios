import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var currentQuestionIndex = 0
    private var score = 0
    private var totalScore = 0
    private var highestScore = 0
    private var highestScoreDate = ""
    private var quizesPlayed = 0
    private var averageAccuracy: Float = 0
    private let dateFormatter = DateFormatter()
    private let dateFormat = "dd.MM.yy HH:mm"

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        dateFormatter.dateFormat = dateFormat
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
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
    private func handleButtonClick(answerWasCorrect: Bool) {
        toggleAnswerButtons()
        if answerWasCorrect {
            score += 1
        }
        setImageBorder(answerWasCorrect: answerWasCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.showNextQuestionOrResults()
            self?.toggleAnswerButtons()
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
            quizesPlayed += 1
            totalScore += score
            if score > highestScore {
                highestScore = score
                highestScoreDate = dateFormatter.string(from: Date())
            }
            averageAccuracy = Float(totalScore * 1000 / (questionsAmount * quizesPlayed)) / 10
            let title = score == questionsAmount ? "Поздравляем!" : "Этот раунд окончен!"
            let resultsViewModel = QuizResultsViewModel(
                title: title,
                text: """
                Ваш результат: \(score)/\(questionsAmount)
                Количество сыгранных квизов: \(quizesPlayed)
                Рекорд: \(highestScore)/\(questionsAmount) (\(highestScoreDate))
                Средняя точность: \(averageAccuracy)%
                """,
                buttonText: "Сыграть еще раз")
            let resultAlertPresenter = ResultAlertPresenter()
            resultAlertPresenter.showResults(quiz: resultsViewModel, alertPresenter: self) { [weak self] _ in
                    guard let
                        self = self
                    else {
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
        let step = QuizStepViewModel(
            image: model.image,
            questionText: model.question,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return step
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(quiz: viewModel)
        }
    }
}
