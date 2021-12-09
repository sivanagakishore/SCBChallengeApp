import Foundation
import Combine
protocol SearchMovieAPIProptol: WebRepository {
    func searchMovies(word: String, pageNo: String) -> AnyPublisher<MovieSearchAPIModel, Error>
    func getMovieFullDetails(movieID: String) -> AnyPublisher<MovieFullDetailsAPIModel, Error>
}
struct SearchMovieAPI: SearchMovieAPIProptol {
    var baseURL: String = ""
    var config: ApiClientConfigProtocol
    init(config: ApiClientConfigProtocol) {
        self.config = config
        self.baseURL = config.baseURL
    }
    func searchMovies(word: String, pageNo: String) -> AnyPublisher<MovieSearchAPIModel, Error> {
        return call(endpoint: SearchMovie(config: config,
                                          word: word, page: pageNo))
    }
    
    func getMovieFullDetails(movieID: String) -> AnyPublisher<MovieFullDetailsAPIModel, Error> {
        return call(endpoint: MovieDetails(config: config, movieId: movieID))
    }
}

// MARK: - Endpoints

extension SearchMovieAPI {
    struct SearchMovie: APICall {
        var config: ApiClientConfigProtocol
        var word: String
        var page: String
        init(config: ApiClientConfigProtocol,
             word: String, page: String) {
            self.config = config
            self.word = word
            self.page = page
        }
        var path: String = ""
        
        var method: String = "GET"
        
        var headers: [String : String]? {
            return self.config.baseHeaders
        }
        
        var queryParameters: [String : String] {
            var queryParam = self.config.baseQueryParams
            queryParam["s"] = self.word
            queryParam["page"] = self.page
            return queryParam
        }
        
        func body() throws -> Data? {
            return nil
        }
    }
    
}

extension SearchMovieAPI {
    struct MovieDetails: APICall {
        
        var config: ApiClientConfigProtocol
        var movieId: String
        init(config: ApiClientConfigProtocol,
             movieId: String) {
            self.config = config
            self.movieId = movieId
        }
        var path: String = ""
        
        var method: String = "GET"
        
        var headers: [String : String]? {
            return self.config.baseHeaders
        }
        
        var queryParameters: [String : String] {
            var queryParam = self.config.baseQueryParams
            queryParam["i"] = movieId
            return queryParam
        }
        
        func body() throws -> Data? {
            return nil
        }
    }
}
