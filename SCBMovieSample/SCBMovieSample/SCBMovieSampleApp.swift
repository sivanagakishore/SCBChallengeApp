
import SwiftUI

@main
struct SCBMovieSampleApp: App {
    var appDI: AppDIProtocol = AppEnvironment()
    var body: some Scene {
        WindowGroup {
            let rootView = SearchMoviesView(viewModel: SearchMoviesViewModel(searchApis: appDI.apiRepository.searchMovieApis))
            rootView
        }
    }
}
