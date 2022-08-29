import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private(set) var totalAccuracy: Double {
        get {
            if userDefaults.object(forKey: Keys.total.rawValue) == nil {
                userDefaults.set(Double(), forKey: Keys.total.rawValue)
            }
            return userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    private(set) var gamesCount: Int {
        get {
            if userDefaults.object(forKey: Keys.gamesCount.rawValue) == nil {
                userDefaults.set(Double(), forKey: Keys.gamesCount.rawValue)
            }
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        if bestGame.isRecord(count) {
            let newBestGame = GameRecord(correct: count, total: amount, date: Date())
            bestGame = newBestGame
        }
        gamesCount += 1
        let accuracy = Double(count * 100 / amount)
        totalAccuracy = Double((totalAccuracy * Double(gamesCount - 1) + accuracy)) / Double(gamesCount)
    }
}
