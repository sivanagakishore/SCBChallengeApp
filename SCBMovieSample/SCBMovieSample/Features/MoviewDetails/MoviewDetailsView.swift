import SwiftUI
import Combine

struct MovieDetailView: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    @Environment(\.imageCache) var cache: ImageCache
    
    var body: some View {
        content
            .onAppear { self.viewModel.loadMovieDetail() }
    }
    
    private var content: some View {
        switch viewModel.state {
        case .loading:
            return spinner.eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .loaded(let movie):
            return self.movie(movie).eraseToAnyView()
        }
    }
    
    private func movie(_ movie: MovieDetailViewModel.MovieDetail) -> some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 10) {
                Text(movie.title)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.blue)
                
                HStack {
                    Text("Released:")
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(alignment: .leading)
                    Text(movie.releasedAt)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(alignment: .leading)
                }
                Divider()
                
                HStack(spacing: 20) {
                    Text(movie.genres)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(movie.duration)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("⭐️ \(movie.rating)").font(.body)
                    
                }
                Divider()
                poster(of: movie)
                VStack(spacing: 20) {
                    Text(movie.overview)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 20) {
                        Text("Director: ")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(movie.director)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(spacing: 20) {
                        Text("Actors: ")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(movie.actors)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }.padding()
        }
    }
    
    private var fillWidth: some View {
        HStack {
            Spacer()
        }
    }
    
    private func poster(of movie: MovieDetailViewModel.MovieDetail) -> some View {
        movie.poster.map { url in
            AsyncImage(
                url: url,
                cache: cache,
                placeholder: self.spinner,
                configuration: { $0.resizable() }
            )
                .aspectRatio(contentMode: .fit)
        }
    }
    
    private var spinner: Spinner { Spinner(isAnimating: true, style: .large) }
    
}
