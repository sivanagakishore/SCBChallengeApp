import SwiftUI
struct ContentView: View {
  @State private var scrollOffset: CGFloat = .zero

  var body: some View {
    ZStack {
      scrollView
      statusBarView
    }
  }

    var scrollView: some View {
        ScrollViewReader { scrollView in
            
            ScrollViewOffset(scrollProxy: scrollView,
                             scrollToId: UUID()) {
                LazyVStack {
                    ForEach(0..<100) { index in
                        Text("\(index)")
                    }
                }
            } onOffsetChange: {
                scrollOffset = $0
            }
        }
    }

  var statusBarView: some View {
    GeometryReader { geometry in
      Color.red
        .opacity(opacity)
        .frame(height: geometry.safeAreaInsets.top, alignment: .top)
        .edgesIgnoringSafeArea(.top)
    }
  }

  var opacity: Double {
    switch scrollOffset {
    case -100...0:
      return Double(-scrollOffset) / 100.0
    case ...(-100):
      return 1
    default:
      return 0
    }
  }
}
