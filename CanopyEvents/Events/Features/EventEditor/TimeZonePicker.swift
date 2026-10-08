import SwiftUI

/// Picks an IANA time zone ("America/Los_Angeles") from a pushed list.
struct TimeZonePicker: View {
    @Binding var identifier: String

    var body: some View {
        Picker("Time zone", selection: $identifier) {
            ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { id in
                Text(id.replacingOccurrences(of: "_", with: " ")).tag(id)
            }
        }
        #if os(macOS)
        .pickerStyle(.menu)
        #else
        .pickerStyle(.navigationLink)
        #endif
    }
}

#Preview {
    @Previewable @State var identifier = "America/Los_Angeles"
    NavigationStack {
        Form { TimeZonePicker(identifier: $identifier) }
    }
    .preferredColorScheme(.dark)
}
