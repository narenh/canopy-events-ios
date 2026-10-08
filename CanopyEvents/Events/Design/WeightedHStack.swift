import SwiftUI

/// A row whose children share its width by weight (e.g. 2, 1, 1 gives
/// half, a quarter and a quarter), with a fixed gap between them. Each
/// child is offered exactly its share; the row is as tall as the tallest.
struct WeightedHStack: Layout {
    var weights: [CGFloat]
    var spacing: CGFloat = 8

    private func widths(for total: CGFloat, count: Int) -> [CGFloat] {
        let w = (0..<count).map { $0 < weights.count ? weights[$0] : 1 }
        let sum = max(w.reduce(0, +), 1)
        let available = max(total - spacing * CGFloat(max(count - 1, 0)), 0)
        return w.map { available * $0 / sum }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        let columns = widths(for: width, count: subviews.count)
        let height = zip(subviews, columns)
            .map { $0.sizeThatFits(ProposedViewSize(width: $1, height: proposal.height)).height }
            .max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columns = widths(for: bounds.width, count: subviews.count)
        var x = bounds.minX
        for (subview, width) in zip(subviews, columns) {
            subview.place(at: CGPoint(x: x, y: bounds.minY), anchor: .topLeading,
                          proposal: ProposedViewSize(width: width, height: bounds.height))
            x += width + spacing
        }
    }
}
