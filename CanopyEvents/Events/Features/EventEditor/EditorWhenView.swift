import SwiftUI

/// When, drawn as big as the event page draws it, each piece tapped to
/// change: the date ("Tuesday, October 13"), the start time, and the end
/// ("+ End time" adds one three hours after the start). The end is one
/// date-and-time picker, so it can be overnight or days later. Under it,
/// the time zone by name, with a Change menu. Dates are picked on the
/// event's own clock. A new event starts with "Pick a date" and "Start
/// time"; its day picked with no time yet makes it 7:00 PM.
struct EditorWhenView: View {
    @Bindable var model: EventEditorModel

    @Environment(\.eventAccent) private var accent
    @State private var editing: Piece?

    private enum Piece: Identifiable {
        case date, start, end
        var id: Self { self }
    }

    private var zone: TimeZone { model.zone }
    /// The moment the zone's name and offsets are worked out for.
    private var when: Date { model.draft.startsAt ?? .now }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            tappable(model.draft.startsAt.map { format($0, date: true) }, placeholder: "Pick a date",
                     font: Typography.whenDate, piece: .date)
            HStack(spacing: Spacing.small) {
                tappable(startWords, placeholder: "Start time", font: Typography.whenTime, piece: .start)
                if let end = model.draft.endsAt {
                    Text("–").font(Typography.whenTime)
                    tappable(endWords(end), placeholder: "", font: Typography.whenTime, piece: .end)
                    Button("Remove end time", systemImage: "xmark.circle.fill") { model.removeEnd() }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(Palette.muted)
                } else if model.draft.startsAt != nil {
                    Button("+ End time") {
                        model.addEnd()
                        editing = .end
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(accent.text)
                }
            }
            EditorZoneLine(identifier: $model.draft.timeZone, date: when)
                .padding(.top, Spacing.xSmall)
        }
        .foregroundStyle(.white)
    }

    /// The start's time, or one picked before its day.
    private var startWords: String? {
        guard let time = model.startTime, let date = time.on(when, in: zone) else { return nil }
        return format(date, time: true)
    }

    /// A piece of the when, underlined with dashes to say it can be
    /// tapped, opening its picker in a popover; dimmed words until it's
    /// picked. An empty date's calendar opens on today, picked (the system
    /// calendar always shows a day as chosen).
    private func tappable(_ words: String?, placeholder: String, font: Font, piece: Piece) -> some View {
        Button {
            if piece == .date, model.draft.startsAt == nil { model.pickStartDay(.now) }
            editing = piece
        } label: {
            Text(words ?? placeholder)
                .font(font)
                .foregroundStyle(Color.white.opacity(words == nil ? 0.55 : 1))
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
            DatePicker("Date", selection: Binding(get: { when }, set: model.pickStartDay),
                       displayedComponents: .date)
                .datePickerStyle(.graphical)
                .frame(minWidth: 320)
        case .start:
            DatePicker("Start time", selection: Binding(get: { shownStart }, set: { model.pickStartTime(ClockTime(of: $0, in: zone)) }),
                       displayedComponents: .hourAndMinute)
                .wheelDatePickerStyle()
                .labelsHidden()
        case .end:
            DatePicker("End time", selection: Binding(get: { model.draft.endsAt ?? when },
                                                      set: { model.draft.endsAt = $0 }),
                       in: when...)
                .wheelDatePickerStyle()
                .labelsHidden()
        }
    }

    /// What the time wheel shows: the start, or 7:00 PM until one's picked.
    private var shownStart: Date {
        (model.startTime ?? .defaultStart).on(when, in: zone) ?? when
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
        guard !calendar.isDate(end, inSameDayAs: when) else { return format(end, time: true) }
        var style = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day().hour().minute()
        style.timeZone = zone
        return end.formatted(style)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.xxLarge) {
        EditorWhenView(model: EventEditorModel(event: PreviewData.event(MockEvents.galleryId)))
        EditorWhenView(model: EventEditorModel(event: nil))
    }
    .padding()
    .canopyScreen()
}
