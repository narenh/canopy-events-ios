import SwiftUI

/// The editor's color sliders, the web's: a short plain stretch at the
/// left end (grey for Color, white for Accent: one value each), then the
/// whole hue wheel, drawn at a lightness you can see (the mesh's own
/// colors are too dark on a thin track). Positions run 0 to `greySteps +
/// 359`. Dragging changes the value at once, so the page behind it
/// previews it live.
struct WheelSlider: View {
    /// The position, 0 to `ThemeSliderScale.maximum`.
    @Binding var value: Int
    /// The left end's color (grey, or white).
    let start: RGB
    /// The thumb's fill.
    let thumbColor: Color
    let label: String
    let valueWords: String

    @State private var width: CGFloat = 0
    private let thumb: CGFloat = 30
    private let maximum = Double(ThemeSliderScale.maximum)

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(LinearGradient(stops: Self.stops(start: start), startPoint: .leading, endPoint: .trailing))
                .frame(height: 14)
                .overlay { Capsule().strokeBorder(.white.opacity(0.55), lineWidth: 1) }
                .padding(.horizontal, thumb / 2)
            Circle()
                .fill(thumbColor)
                .overlay { Circle().strokeBorder(.white, lineWidth: 3) }
                .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                .frame(width: thumb, height: thumb)
                .offset(x: CGFloat(Double(value) / maximum) * max(0, width - thumb))
        }
        .frame(height: 44)
        .contentShape(.rect)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
            let usable = max(1, width - thumb)
            let fraction = min(max((drag.location.x - thumb / 2) / usable, 0), 1)
            value = Int((fraction * maximum).rounded())
        })
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(valueWords)
        .accessibilityAdjustableAction { direction in
            value = min(max(value + (direction == .increment ? 10 : -10), 0), ThemeSliderScale.maximum)
        }
    }

    /// The plain stretch, then the wheel at OKLCH lightness 0.68 and
    /// chroma 0.15, every 30° (the web's `hueTrack`).
    static func stops(start: RGB) -> [Gradient.Stop] {
        let maximum = Double(ThemeSliderScale.maximum)
        let end = Double(ThemeSliderScale.greySteps - 1) / maximum
        var stops: [Gradient.Stop] = [.init(color: start.color, location: 0), .init(color: start.color, location: end)]
        for hue in stride(from: 0, through: 360, by: 30) {
            let at = Double(ThemeSliderScale.greySteps + min(hue, 359)) / maximum
            stops.append(.init(color: OKLCH.rgb(L: 0.68, C: 0.15, h: Double(hue % 360)).color, location: at))
        }
        return stops
    }

    /// The Color slider's track start: a grey exactly as light as the colors.
    static let grey = OKLCH.rgb(L: 0.68, C: 0, h: 0)
}

#Preview {
    @Previewable @State var value = 173
    WheelSlider(value: $value, start: WheelSlider.grey, thumbColor: .green, label: "Color", valueWords: "\(value)")
        .padding()
        .canopyScreen()
}
