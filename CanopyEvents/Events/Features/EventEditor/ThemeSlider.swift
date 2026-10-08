import SwiftUI

/// The event's colour as a slider, the web's: a grey stretch at the left
/// end (no colour), then the whole hue wheel, drawn at a lightness you can
/// see (the mesh's own colours are too dark on a thin track). The thumb
/// is filled with the theme's brightest glow. Dragging changes the theme
/// at once, so the page behind it previews it live.
struct ThemeSlider: View {
    @Binding var theme: EventTheme

    @State private var width: CGFloat = 0
    private let thumb: CGFloat = 30
    private let maximum = Double(ThemeSliderScale.maximum)

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(LinearGradient(stops: Self.trackStops, startPoint: .leading, endPoint: .trailing))
                .frame(height: 14)
                .overlay { Capsule().strokeBorder(.white.opacity(0.55), lineWidth: 1) }
                .padding(.horizontal, thumb / 2)
            Circle()
                .fill(ThemeColors(theme).glow3.color)
                .overlay { Circle().strokeBorder(.white, lineWidth: 3) }
                .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                .frame(width: thumb, height: thumb)
                .offset(x: position * max(0, width - thumb))
        }
        .frame(height: 44)
        .contentShape(.rect)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
            let usable = max(1, width - thumb)
            let fraction = min(max((drag.location.x - thumb / 2) / usable, 0), 1)
            theme = ThemeSliderScale.theme(at: Int((fraction * maximum).rounded()))
        })
        .accessibilityElement()
        .accessibilityLabel("Colour")
        .accessibilityValue(Self.words(for: theme))
        .accessibilityAdjustableAction { direction in
            let step = direction == .increment ? 10 : -10
            theme = ThemeSliderScale.theme(at: ThemeSliderScale.value(for: theme) + step)
        }
    }

    private var position: CGFloat {
        CGFloat(Double(ThemeSliderScale.value(for: theme)) / maximum)
    }

    /// "No colour", "Canopy green", or "300°", as the web says it.
    static func words(for theme: EventTheme) -> String {
        switch theme {
        case .grayscale: "No colour"
        case .canopyGreen: "Canopy green"
        case .hue(let hue): "\(hue)°"
        }
    }

    /// Grey, then the wheel at OKLCH lightness 0.68 and chroma 0.15, every 30°.
    private static let trackStops: [Gradient.Stop] = {
        let maximum = Double(ThemeSliderScale.maximum)
        let grey = OKLCH.rgb(L: 0.68, C: 0, h: 0).color
        let greyEnd = Double(ThemeSliderScale.greySteps - 1) / maximum
        var stops: [Gradient.Stop] = [.init(color: grey, location: 0), .init(color: grey, location: greyEnd)]
        for hue in stride(from: 0, through: 360, by: 30) {
            let at = Double(ThemeSliderScale.greySteps + min(hue, 359)) / maximum
            stops.append(.init(color: OKLCH.rgb(L: 0.68, C: 0.15, h: Double(hue % 360)).color, location: at))
        }
        return stops
    }()
}

#Preview {
    @Previewable @State var theme = EventTheme.canopyGreen
    VStack {
        ThemeSlider(theme: $theme)
        Text(ThemeSlider.words(for: theme))
    }
    .padding()
    .canopyScreen(theme: theme)
}
