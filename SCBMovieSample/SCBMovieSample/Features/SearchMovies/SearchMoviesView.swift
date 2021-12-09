import Foundation
import SwiftUI
import Combine
struct SearchMoviesView: View {
    
    @ObservedObject var viewModel: SearchMoviesViewModel
    var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, startSearch: {
                    self.viewModel.onSearch(word: searchText)
                }).padding(.top, 0)
                content
                    .navigationBarTitle("Movies")
            }
        }
    }
    
    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Color.clear.eraseToAnyView()
        case .searching:
            return CustomSpinner().eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .searchCompleted(let movies, let pageNo, let scrollTo):
            return list(of: movies, pageNo: pageNo,
                        scrollTo: scrollTo).eraseToAnyView()
        }
    }
    
    private func list(of movies: [SearchMoviesViewModel.ListItem], pageNo: Int,
                      scrollTo: UUID) -> some View {
        return ScrollViewReader { scrollView in
            
            ScrollViewOffset(scrollProxy: scrollView, scrollToId: scrollTo) {
                LazyVGrid(columns: gridItemLayout, spacing: 20) {
                    ForEach(movies, id: \.id) { item in
                        NavigationLink(
                            destination: MovieDetailView(viewModel: MovieDetailViewModel(searchApis: self.viewModel.searchApis, movieId: item.movieId)),
                            label: { MovieSearchItemView(movie: item).id(item.id) }
                        )
                        
                    }
                }
            } onOffsetChange: { offset in
                if fabs(offset) > Double(500 * pageNo) {
                    self.viewModel.onSearch(word: searchText)
                }
            }
        }
    }
}

extension SearchMoviesView {
    var drag: some Gesture {
        DragGesture()
            .onChanged { state in
                print("changing")
            }
            .onEnded { state in
                print("ended")
            }
    }
}
struct MovieSearchItemView: View {
    let movie: SearchMoviesViewModel.ListItem
    @Environment(\.imageCache) var cache: ImageCache
    
    var body: some View {
        VStack {
            title
            poster
        }
    }
    
    private var title: some View {
        Text(movie.title)
            .font(.footnote)
            .padding()
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }
    
    private var poster: some View {
        movie.poster.map { url in
            AsyncImage(
                url: url,
                cache: cache,
                placeholder: spinner,
                configuration: { $0.resizable().renderingMode(.original) }
            )
        }
        .aspectRatio(contentMode: .fit)
        .frame(idealHeight: 100)
    }
    
    private var spinner: some View {
        Spinner(isAnimating: true, style: .medium)
    }
}
