import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
extension RangeReplaceableCollection where Self: StringProtocol {
    var digits: Self {
        return filter(("0"..."9").contains)
    }
}
