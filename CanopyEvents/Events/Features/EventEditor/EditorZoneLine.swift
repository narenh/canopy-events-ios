import SwiftUI

/// The editor's time zone by name ("Pacific Time"), with a Change menu of
/// nearby zones (`TimeZoneChoices`) and "Other time zones…" to search.
struct EditorZoneLine: View {
    @Binding var identifier: String
    /// The moment the name and offsets are for: the start, or now.
    let date: Date

    @Environment(\.eventAccent) private var accent
    @State private var searchingZones = false

    private var zone: TimeZone { TimeZone(identifier: identifier) ?? .current }

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(TimeZoneName.friendly(zone, at: date))
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
            Menu {
                ForEach(TimeZoneChoices.nearby(viewer: .current, at: date, selected: zone)) { choice in
                    Button {
                        identifier = choice.identifier
                    } label: {
                        if choice.isSelected {
                            Label(choice.name, systemImage: "checkmark")
                        } else {
                            Text(choice.name)
                        }
                        if choice.isYours { Text("Your time zone") }
                    }
                }
                Divider()
                Button("Other time zones…") { searchingZones = true }
            } label: {
                Text("Change").font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(accent.text)
            .accessibilityLabel("Change time zone")
        }
        .sheet(isPresented: $searchingZones) {
            TimeZoneSearchSheet(identifier: $identifier, date: date)
        }
    }
}

#Preview {
    @Previewable @State var identifier = "America/New_York"
    EditorZoneLine(identifier: $identifier, date: .now)
        .padding()
        .canopyScreen()
}
