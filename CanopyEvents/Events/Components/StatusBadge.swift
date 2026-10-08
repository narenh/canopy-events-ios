import SwiftUI

/// Your part in an event, or someone's status, as a pill in the fixed
/// status colors (docs/api.md, "Status colors"): the same on every card,
/// never the event's theme or accent. Dark text on a light pill; can't go
/// and removed are plain glass. Co-hosting reads "Hosting".
struct StatusBadge: View {
    let kind: Kind

    enum Kind: Hashable {
        case hosting
        case status(RSVPStatus)
    }

    var body: some View {
        let words = Text(title.uppercased())
            .font(Typography.tag)
            .tracking(0.4)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
        if let colors {
            words
                .foregroundStyle(colors.text.color)
                .background(colors.pill.color, in: .rect(cornerRadius: 8))
        } else {
            words
                .foregroundStyle(.white)
                .background(.white.opacity(0.10), in: .rect(cornerRadius: 8))
                .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(.white.opacity(0.55), lineWidth: 1) }
        }
    }

    private var title: String {
        switch kind {
        case .hosting: "Hosting"
        case .status(.waitlisted): "On the waitlist"
        case .status(let status): status.title
        }
    }

    /// The pill and its text; nil for plain glass.
    private var colors: (pill: RGB, text: RGB)? {
        switch kind {
        case .hosting: (RGB(hex: "#6CB4FF"), RGB(hex: "#03122A"))
        case .status(.going): (RGB(hex: "#2EC44F"), RGB(hex: "#03190A"))
        case .status(.maybe): (RGB(hex: "#F2C94C"), RGB(hex: "#1F1600"))
        case .status(.waitlisted): (RGB(hex: "#FF8A3D"), RGB(hex: "#2A1100"))
        case .status(.invited): (RGB(hex: "#C4CCC7"), RGB(hex: "#121815"))
        case .status(.notGoing), .status(.removed): nil
        }
    }
}

extension StatusBadge {
    /// Your part in an event: hosting (co-hosting too), else your answer.
    init?(event: Event) {
        if event.viewer?.isHost == true {
            self.init(kind: .hosting)
        } else if let status = event.myStatus {
            self.init(kind: .status(status))
        } else {
            return nil
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        StatusBadge(kind: .hosting)
        ForEach(RSVPStatus.allCases, id: \.self) { StatusBadge(kind: .status($0)) }
    }
    .padding()
    .canopyScreen()
}
