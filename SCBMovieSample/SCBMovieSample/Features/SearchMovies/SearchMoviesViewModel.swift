import Foundation
import Combine
protocol SearchMoviesViewModelProtocol: ObservableObject {
    var state: SearchMoviesViewModel.State { get set }
    func onSearch(word: String)
}
final class SearchMoviesViewModel: SearchMoviesViewModelProtocol {
   
    @Published var state = State.idle
    private var searchMoviesCancellable = Set<AnyCancellable>()
    
    var scrollToId: UUID = UUID()
    var pageNo: Int = 0
    var pageItemsLimit: Int = 10
    var hasMoreRecords: Bool = false
    var currentSearchWord: String = ""
    var totalItems: [ListItem] = []
    var searchApis: SearchMovieAPIProptol
    
    init(searchApis: SearchMovieAPIProptol) {
        self.searchApis = searchApis
    }
    
    func onSearch(word: String) {
        guard !word.isEmpty else {
            clear()
            state = .idle
            return
        }
        if word != currentSearchWord {
            resetPage()
        }
        currentSearchWord = word
        state = .searching
        pageNo += 1
        let moviesPublisher = self.searchApis.searchMovies(word: currentSearchWord,
                                                           pageNo: "\(pageNo)")
        moviesPublisher.sink(receiveCompletion: { [weak self] completion in
            if case .failure(let error) = completion {
                self?.state = .error(error)
                self?.clear()
            }
        }, receiveValue: { [weak self] response in
            self?.processResponse(response: response)
        }).store(in: &searchMoviesCancellable)
    }
    
    func processResponse(response: MovieSearchAPIModel) {
        print("First sink retrieved object \(response)")
        hasMoreRecords = true
        if (Int(response.totalResults ?? "0") ?? 0) < pageNo * pageItemsLimit {
            hasMoreRecords = false
        }
        let items = response.movieList?.map({
            return ListItem(movieId: $0.imdbID ?? "",
                            title: $0.title ?? "",
                            poster_path: $0.poster ?? "")
        })
        scrollToId = totalItems.last?.id ?? UUID()
        totalItems.append(contentsOf: items ?? [])
        self.state = .searchCompleted(totalItems, pageNo, scrollToId)
    }
    
    func clear() {
        currentSearchWord = ""
        resetPage()
    }
    func resetPage() {
        totalItems = []
        pageNo = 0
        hasMoreRecords = false
    }
}
extension SearchMoviesViewModel {
    
    enum State {
        case idle
        case searching
        case searchCompleted([ListItem], Int, UUID)
        case error(Error)
    }
    
    struct ListItem: Identifiable {
        var id = UUID()
        let movieId: String
        let title: String
        var poster: URL?
        init(movieId: String, title: String, poster_path: String) {
            self.movieId = movieId
            self.title = title
            self.poster = URL(string: poster_path)
        }
    }
}
