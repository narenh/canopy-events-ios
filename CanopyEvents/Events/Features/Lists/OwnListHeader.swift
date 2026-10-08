import SwiftUI

/// The top of one of your lists: its name, how many are on it, Share link
/// and Show QR side by side, and the link itself.
struct OwnListHeader: View {
    let list: OwnedList
    let onShowQR: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(list.name)
                    .font(Typography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)
                Text(InvitePicker.count(list.memberCount))
                    .foregroundStyle(Palette.muted)
            }
            WeightedHStack(weights: [1, 1], spacing: Spacing.small) {
                if let url = URL(string: list.url) {
                    ShareLink(item: url, subject: Text(list.name), message: Text("Join \(list.name) on Canopy")) {
                        wide("Share link", systemImage: "square.and.arrow.up")
                    }
                    .accentProminentButtonStyle()
                }
                Button(action: onShowQR) { wide("Show QR", systemImage: "qrcode") }
                    .glassButtonStyle()
            }
            .controlSize(.large)
            Text(ListQRItem(list).shortURL)
                .font(.callout.monospaced())
                .foregroundStyle(Palette.muted)
                .textSelection(.enabled)
                .accessibilityLabel("Link: \(list.url)")
        }
        .glassCard()
    }

    private func wide(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(Typography.button)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    OwnListHeader(list: OwnedList(id: "x", name: "Drag Race", code: "9xQ2mPc7LtRe", url: "https://events.canopysf.com/l/9xQ2mPc7LtRe",
                                  memberCount: 20, createdAt: .now)) {}
        .padding()
        .canopyScreen()
}
