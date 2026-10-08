import SwiftUI

/// When, drawn as big as the event page draws it, each piece tapped to
/// change: the date ("Tuesday, October 13"), the start time, and the end
/// ("+ End time" adds one three hours after the start). The end is one
/// date-and-time picker, so it can be overnight or days later. Under it,
/// the time zone by name, with a Change menu. Dates are picked on the
/// event's own clock.
struct EditorWhenView: View {
    @Bindable var model: EventEditorModel

    @Environment(\.eventAccent) private var accent
    @State private var editing: Piece?
    @State private var searchingZones = false

    private enum Piece: Identifiable {
        case date, start, end
        var id: Self { self }
    }

    private var zone: TimeZone { TimeZone(identifier: model.draft.timeZone) ?? .current }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            tappable(format(model.draft.startsAt, date: true), font: Typography.whenDate, piece: .date)
            HStack(spacing: Spacing.small) {
                tappable(format(model.draft.startsAt, time: true), font: Typography.whenTime, piece: .start)
                if let end = model.draft.endsAt {
                    Text("–").font(Typography.whenTime)
                    tappable(endWords(end), font: Typography.whenTime, piece: .end)
                    Button("Remove end time", systemImage: "xmark.circle.fill") { model.removeEnd() }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(Palette.muted)
                } else {
                    Button("+ End time") {
                        model.addEnd()
                        editing = .end
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(accent.text)
                }
            }
            zoneLine.padding(.top, Spacing.xSmall)
        }
        .foregroundStyle(.white)
        .sheet(isPresented: $searchingZones) {
            TimeZoneSearchSheet(identifier: $model.draft.timeZone, date: model.draft.startsAt)
        }
    }

    private var zoneLine: some View {
        HStack(spacing: Spacing.small) {
            Text(TimeZoneName.friendly(zone, at: model.draft.startsAt))
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
            Menu {
                ForEach(TimeZoneChoices.nearby(viewer: .current, at: model.draft.startsAt, selected: zone)) { choice in
                    Button {
                        model.draft.timeZone = choice.identifier
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
    }

    /// A piece of the when, underlined with dashes to say it can be
    /// tapped, opening its picker in a popover.
    private func tappable(_ words: String, font: Font, piece: Piece) -> some View {
        Button {
            editing = piece
        } label: {
            Text(words)
                .font(font)
                .underline(pattern: .dash, color: .white.opacity(0.5))
                .multilineTextAlignment(.leading)
        }
        .buttonStyle(.plain)
        .popover(item: Binding(get: { editing == piece ? piece : nil }, set: { editing = $0 })) { _ in
            picker(for: piece)
                .padding()
                .environment(\.timeZone, zone)
                .presentationCompactAdaptation(.popover)
        }
    }

    @ViewBuilder private func picker(for piece: Piece) -> some View {
        switch piece {
        case .date:
            DatePicker("Date", selection: Binding(get: { model.draft.startsAt }, set: model.setStart),
                       displayedComponents: .date)
                .datePickerStyle(.graphical)
                .frame(minWidth: 320)
        case .start:
            DatePicker("Start time", selection: Binding(get: { model.draft.startsAt }, set: model.setStart),
                       displayedComponents: .hourAndMinute)
                .wheelDatePickerStyle()
                .labelsHidden()
        case .end:
            DatePicker("End time", selection: Binding(get: { model.draft.endsAt ?? model.draft.startsAt },
                                                      set: { model.draft.endsAt = $0 }),
                       in: model.draft.startsAt...)
                .wheelDatePickerStyle()
                .labelsHidden()
        }
    }

    private func format(_ date: Date, date showsDate: Bool = false, time showsTime: Bool = false) -> String {
        var style = showsDate ? Date.FormatStyle().weekday(.wide).month(.wide).day() : Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = zone
        return date.formatted(style)
    }

    /// The end's time, or "Sun, Oct 11, 11:00 AM" when it's another day.
    private func endWords(_ end: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        guard !calendar.isDate(end, inSameDayAs: model.draft.startsAt) else { return format(end, time: true) }
        var style = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day().hour().minute()
        style.timeZone = zone
        return end.formatted(style)
    }
}

#Preview {
    EditorWhenView(model: EventEditorModel(event: PreviewData.event(MockEvents.galleryId)))
        .padding()
        .canopyScreen()
}
