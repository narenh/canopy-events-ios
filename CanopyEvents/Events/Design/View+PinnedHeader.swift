import SwiftUI

extension View {
    /// Keeps a header picture exactly where it is while the scroll view is
    /// pulled down past its top: same place, same size, no zoom. The page's
    /// content (the fade, the title and everything after) rubber-bands down
    /// as usual and slides over the bottom of the picture, so the picture
    /// has to be drawn under it. Scrolling up moves it with the page.
    /// `overscroll` comes from `trackingOverscroll`.
    func pinnedWhilePulled(_ overscroll: CGFloat) -> some View {
        offset(y: -max(0, overscroll))
    }

    /// How far the scroll view is pulled down past its top, in points (0
    /// otherwise), for `pinnedWhilePulled`. Apply to the `ScrollView`.
    func trackingOverscroll(_ overscroll: Binding<CGFloat>) -> some View {
        onScrollGeometryChange(for: CGFloat.self) { geometry in
            max(0, -(geometry.contentOffset.y + geometry.contentInsets.top))
        } action: { _, pull in
            overscroll.wrappedValue = pull
        }
    }
}
