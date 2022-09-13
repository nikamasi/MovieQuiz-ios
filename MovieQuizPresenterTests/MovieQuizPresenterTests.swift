import XCTest
@testable import MovieQuiz


final class MovieQuizViewControllerProtocolMock: UIViewController, MovieQuizViewControllerProtocol {
    func showQuestion(quiz step: QuizStepViewModel) {
    }
    func setImageBorder(answerWasCorrect: Bool) {
    }
    func showLoadingIndicator() {
    }
    func toggleAnswerButtons() {
    }
    func startNewRound() {
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerProtocolMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        guard let imageData = UIImage(named: "The Dark Knight")?.pngData() else {
            return
        }
        let question = QuizQuestion(image: imageData, rating: 1.0, question: "Question Text", answer: true)
        let viewModel = presenter.convert(model: question)
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.questionText, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
