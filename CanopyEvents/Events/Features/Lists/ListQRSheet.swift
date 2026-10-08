import SwiftUI

/// "Scan to join": each list's name, its QR code as big as the screen
/// allows, and the link, to show at the door (the web's `listQrSheet`).
struct ListQRSheet: View {
    let lists: [ListQRItem]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxLarge) {
                    ForEach(lists) { list in
                        VStack(spacing: Spacing.medium) {
                            Text(list.name)
                                .font(Typography.sectionTitle)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)
                            QRCodeView(url: list.url, name: list.name)
                                .frame(maxWidth: 420)
                            Text(list.shortURL)
                                .font(.callout.monospaced())
                                .foregroundStyle(Palette.muted)
                                .multilineTextAlignment(.center)
                                .textSelection(.enabled)
                        }
                    }
                }
                .padding(Spacing.large)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Scan to join")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .close) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ListQRSheet(lists: [
        ListQRItem(id: "a", name: "Drag Race", url: "https://events.canopysf.com/l/9xQ2mPc7LtRe"),
        ListQRItem(id: "b", name: "Climbing", url: "https://events.canopysf.com/l/Cl7mB3rsJoin"),
    ])
    .preferredColorScheme(.dark)
}
