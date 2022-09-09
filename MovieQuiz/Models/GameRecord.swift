import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isRecord(_ score: Int) -> Bool {
        return score > correct
    }
}
