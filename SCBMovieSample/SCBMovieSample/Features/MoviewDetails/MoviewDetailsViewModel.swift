import Foundation
import Combine

protocol MovieDetailViewModelProtocol: ObservableObject {
    var state: MovieDetailViewModel.State { get set }
    func loadMovieDetail()
}

final class MovieDetailViewModel: ObservableObject {
    @Published var state = State.loading
    
    private var moviewDetailCancellable = Set<AnyCancellable>()
    var searchApis: SearchMovieAPIProptol
    var movieId: String
    init(searchApis: SearchMovieAPIProptol, movieId: String) {
        self.searchApis = searchApis
        self.movieId = movieId
    }
    
    func loadMovieDetail() {
        let moviesPublisher = self.searchApis.getMovieFullDetails(movieID: self.movieId)
        
        moviesPublisher.sink(receiveCompletion: { [weak self] completion in
            if case .failure(let error) = completion {
                self?.state = .error(error)
            }
        }, receiveValue: { [weak self] response in
            self?.processResponse(response: response)
        }).store(in: &moviewDetailCancellable)
    }
    
    func processResponse(response: MovieFullDetailsAPIModel) {
        let movieDetail: MovieDetail = MovieDetail(movie: response)
        self.state = .loaded(movieDetail)
    }
    
}

// MARK: - Inner Types

extension MovieDetailViewModel {
    enum State {
        case loading
        case loaded(MovieDetail)
        case error(Error)
    }
    
    struct MovieDetail {
        let id: String
        let title: String
        let year: String
        let overview: String
        let poster: URL?
        let rating: String
        let duration: String
        var genres: String
        let releasedAt: String
        let language: String
        let director: String
        let actors: String
        
        init(movie: MovieFullDetailsAPIModel) {
            id = movie.imdbID ?? "N/A"
            title = movie.title ?? "N/A"
            year = movie.year ?? "N/A"
            overview = movie.plot ?? "N/A"
            self.poster = URL(string: movie.poster ?? "N/A")
            self.rating = movie.imdbRating ?? "N/A"
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = [.minute, .hour]
            let time = Int((movie.runtime ?? "").digits)
            duration = time.flatMap { formatter.string(from: TimeInterval($0 * 60)) } ?? "N/A"
            genres = movie.genre ?? "N/A"
            releasedAt = movie.released ?? "N/A"
            director = movie.director ?? "N/A"
            actors = movie.actors ?? "N/A"
            language = movie.language ?? "N/A"
        }
    }
}

