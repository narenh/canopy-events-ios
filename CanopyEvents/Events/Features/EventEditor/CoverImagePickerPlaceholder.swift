import SwiftUI

/// Where the cover image picker will go. Uploading needs the API's cover
/// image endpoint, which doesn't exist yet, so for now it only shows the
/// current cover and a disabled button.
struct CoverImagePickerPlaceholder: View {
    let currentUrl: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            CoverImage(url: currentUrl)
                .frame(height: 140)
                .clipShape(.rect(cornerRadius: Radius.small))
            Button("Choose a cover image", systemImage: "photo") {}
                .disabled(true)
            Text("Cover uploads are coming soon.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    Form {
        CoverImagePickerPlaceholder(currentUrl: nil)
    }
    .preferredColorScheme(.dark)
}
