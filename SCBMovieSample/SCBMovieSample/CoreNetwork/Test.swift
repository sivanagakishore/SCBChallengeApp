import Foundation
import Combine

enum APIError2: Error, LocalizedError {
    case unknown, apiError(reason: String)

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason):
            return reason
        }
    }
}

func fetch(url: URL) -> AnyPublisher<Data, APIError2> {
    let request = URLRequest(url: url)

    return URLSession.DataTaskPublisher(request: request, session: .shared)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw APIError2.unknown
            }
            return data
        }
        .mapError { error in
            if let error = error as? APIError2 {
                return error
            } else {
                return APIError2.apiError(reason: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
}


