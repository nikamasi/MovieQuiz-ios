import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    private var mostPopularMoviesURL: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_kiwxbi4y") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            switch result {
            case .success(let data):
                do {
                let movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                handler(.success(movies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
