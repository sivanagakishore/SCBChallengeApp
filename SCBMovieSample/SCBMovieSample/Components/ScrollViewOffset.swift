import SwiftUI
var isScrollToRequired: Bool = false
struct ScrollViewOffset<Content: View>: View {
    let onOffsetChange: (CGFloat) -> Void
    let content: () -> Content
    var scrollToId: UUID
    let scrollProxy: ScrollViewProxy
    init(scrollProxy: ScrollViewProxy,
         scrollToId: UUID,
         @ViewBuilder content: @escaping () -> Content,
         onOffsetChange: @escaping (CGFloat) -> Void) {
        self.onOffsetChange = onOffsetChange
        self.content = content
        self.scrollToId = scrollToId
        self.scrollProxy = scrollProxy
        isScrollToRequired = true
    }
    
    var body: some View {
        ScrollView {
            offsetReader
            content()
                .padding(.top, -8)
        }
        .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChangeLocal)
        
    }
    func scroll() -> some View {
        if isScrollToRequired {
            DispatchQueue.main.async {
                self.scrollProxy.scrollTo(scrollToId, anchor: .top)
                isScrollToRequired = false
            }
        }
        return self
    }
    var dummyView: some View {
        Text("").frame(height: 0)
    }
    var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("frameLayer")).minY
                )
        }
        .frame(height: 0)
    }
    
    func onOffsetChangeLocal(offset: CGFloat) {
        self.onOffsetChange(offset)
    }
    
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
