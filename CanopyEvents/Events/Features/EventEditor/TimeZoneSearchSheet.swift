import SwiftUI

/// "Other time zones…": every zone, searchable, by friendly name with the
/// city under it and the offset small, west to east at the event's date.
struct TimeZoneSearchSheet: View {
    @Binding var identifier: String
    let date: Date

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var zones: [TimeZoneChoice] = []

    private var matches: [TimeZoneChoice] {
        let words = query.trimmingCharacters(in: .whitespaces)
        guard !words.isEmpty else { return zones }
        return zones.filter {
            $0.name.localizedStandardContains(words) || $0.city.localizedStandardContains(words)
                || $0.identifier.localizedStandardContains(words)
        }
    }

    var body: some View {
        NavigationStack {
            List(matches) { zone in
                Button {
                    identifier = zone.identifier
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                            Text(zone.name)
                            Text(zone.city).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(zone.offsetWords).font(.footnote).foregroundStyle(.secondary)
                        if zone.identifier == identifier {
                            Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if !zones.isEmpty && matches.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, prompt: "Search time zones")
            .navigationTitle("Time zone")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) { dismiss() }
                }
            }
            .task { zones = TimeZoneChoices.all(at: date) }
        }
    }
}

#Preview {
    @Previewable @State var identifier = "America/Los_Angeles"
    TimeZoneSearchSheet(identifier: $identifier, date: .now)
}
