import Foundation
import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount = 10
    var score = 0
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0

    var questionFactory: QuestionFactoryProtocol?
    private var viewController: MovieQuizViewControllerProtocol?
    private var statisticService: StatisticService

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        let step = QuizStepViewModel(
            image: image,
            questionText: model.question,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return step
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        let answerWasCorrect = givenAnswer == currentQuestion.answer
        if answerWasCorrect {
            score += 1
        }
        viewController?.toggleAnswerButtons()
        viewController?.setImageBorder(answerWasCorrect: answerWasCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func showNextQuestionOrResults() {
        if !isLastQuestion() {
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        } else {
            let resultsViewModel = makeResultMessage()
            let resultAlertPresenter = AlertPresenter()
            resultAlertPresenter.showResults(quiz: resultsViewModel, alertPresenter: viewController!) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.viewController?.startNewRound()
            }
        }
    }

    func makeResultMessage() -> QuizResultsViewModel {
        statisticService.store(correct: score, total: questionsAmount)
        let title = score == questionsAmount ? "Поздравляем!" : "Этот раунд окончен!"
        return QuizResultsViewModel(
            title: title,
            buttonText: "Сыграть еще раз",
            stats: statisticService,
            questionsAmount: questionsAmount,
            score: score)
    }

    func restartGame() {
        currentQuestionIndex = 0
        score = 0
        questionFactory?.requestNextQuestion()
    }
// MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let errorPresenter = AlertPresenter()
        errorPresenter.showError(
            message: error.localizedDescription,
            title: "Ошибка при получении данных",
            buttonTitle: "Попробовать еще раз",
            alertPresenter: viewController!) { [weak self] _ in
                self?.restartGame()
            return
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion) {
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuestion(quiz: viewModel)
            self?.viewController?.toggleAnswerButtons()
        }
    }
}
