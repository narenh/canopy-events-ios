import SwiftUI

/// A link's QR code, black on its own white tile, as big as it's given,
/// with crisp modules. For lists, to show at a door.
struct QRCodeView: View {
    let url: String
    /// What the link is for, for VoiceOver: "QR code for the Drag Race link".
    let name: String
    private let image: CGImage?

    init(url: String, name: String) {
        self.url = url
        self.name = name
        self.image = QRCode.image(for: url)
    }

    var body: some View {
        if let image {
            Image(decorative: image, scale: 1)
                .interpolation(.none)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: Radius.small))
                .accessibilityElement()
                .accessibilityLabel("QR code for the \(name) link")
                .accessibilityAddTraits(.isImage)
        }
    }
}

#Preview {
    QRCodeView(url: "https://events.canopysf.com/l/9xQ2mPc7LtRe", name: "Drag Race")
        .frame(width: 280)
        .padding()
        .canopyScreen()
}
