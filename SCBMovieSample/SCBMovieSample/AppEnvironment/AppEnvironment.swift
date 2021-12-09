import Foundation
protocol AppDIProtocol {
    var apiClientConfig: ApiClientConfigProtocol { get }
    var apiRepository: ClientApiRepositoryProtocol { get }
}
protocol ApiClientConfigProtocol {
    var baseURL: String { get set }
    var baseHeaders: [String: String] { get set }
    var baseQueryParams: [String: String] { get set }
}

protocol ClientApiRepositoryProtocol {
    var searchMovieApis: SearchMovieAPIProptol { get }
}

class AppEnvironment: AppDIProtocol {
    var apiClientConfig: ApiClientConfigProtocol = ApiClientConfig()
    
    lazy var apiRepository: ClientApiRepositoryProtocol = {
       return  ClientApiRepo(config: apiClientConfig)
    }()
 
}

extension AppEnvironment {
    class ApiClientConfig: ApiClientConfigProtocol {
        var baseURL: String = "http://www.omdbapi.com"
        var baseHeaders: [String: String] = ["Content-Type": "application/json",
                "Accept": "application/json"]
        var baseQueryParams: [String: String] = ["apikey": "b9bd48a6",
                                             "type": "movie"]
    }
}

extension AppEnvironment {
    class ClientApiRepo: ClientApiRepositoryProtocol {
        var config: ApiClientConfigProtocol
        lazy var searchMovieApis: SearchMovieAPIProptol = {
            return SearchMovieAPI(config: config)
        }()
        
        init(config: ApiClientConfigProtocol) {
            self.config = config
        }
    }
}
