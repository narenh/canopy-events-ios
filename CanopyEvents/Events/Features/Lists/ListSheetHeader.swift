import SwiftUI

/// The top of a list's sheet: its QR code when shown (big, for the door),
/// the link, and Share, Copy and QR side by side (words only, so the
/// three fit across a phone; VoiceOver hears the same words).
struct ListSheetHeader: View {
    let list: OwnedList
    @Binding var showsQR: Bool
    /// After Copy: the sheet says "Link copied."
    let onCopied: () -> Void

    var body: some View {
        VStack(spacing: Spacing.medium) {
            if showsQR {
                QRCodeView(url: list.url, name: list.name)
                    .frame(maxWidth: 320)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
            Text(ListQRItem(list).shortURL)
                .font(.callout.monospaced())
                .foregroundStyle(Palette.muted)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: showsQR ? .center : .leading)
                .accessibilityLabel("\(list.name) link: \(list.url)")
            HStack(spacing: Spacing.small) {
                if let url = URL(string: list.url) {
                    ShareLink(item: url, subject: Text(list.name), message: Text("Join \(list.name) on Canopy")) {
                        wide("Share", systemImage: "square.and.arrow.up")
                    }
                    .accentProminentButtonStyle()
                }
                Button {
                    Clipboard.copy(list.url)
                    onCopied()
                } label: {
                    wide("Copy", systemImage: "doc.on.doc")
                }
                .glassButtonStyle()
                Button {
                    withAnimation(.snappy) { showsQR.toggle() }
                } label: {
                    wide("QR", systemImage: "qrcode")
                }
                .glassButtonStyle()
                .accessibilityAddTraits(showsQR ? .isSelected : [])
                .accessibilityHint(showsQR ? "Hides the QR code" : "Shows the QR code")
            }
            .controlSize(.large)
        }
        .glassCard()
    }

    private func wide(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .labelStyle(.titleOnly)
            .font(Typography.button)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var showsQR = true
    ScrollView {
        ListSheetHeader(list: PreviewData.ownedList(), showsQR: $showsQR) {}
            .padding()
    }
    .canopyScreen()
}
