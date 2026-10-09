import PhotosUI
import SwiftUI

/// The editor's cover, drawn as the event page's hero (3:2, fading itself
/// out the same way), with a dashed line where the clear 2:1 ends, so the host sees
/// what stays clear. A gallery button (a TMDB background, when the set is
/// on), a camera button (add or change a photo) and a × (remove) sit top
/// right as 48 pt dark glass circles. Nothing uploads until Save. A copy
/// shows its original's cover until it's taken off or replaced.
/// Pulled down, the picture (with its buttons) stays put and the fields
/// slide down over it, as on the page.
struct EditorHeroView: View {
    @Bindable var model: EventEditorModel
    var isInset = false
    /// How far the editor is pulled down past its top (the cover stays put).
    var overscroll: CGFloat = 0

    @State private var item: PhotosPickerItem?
    @State private var backgrounds: BackgroundList?
    @State private var choosesBackground = false
    @Environment(\.eventsRepository) private var repository

    var body: some View {
        picture
            .aspectRatio(3 / 2, contentMode: .fit)
            .heroFade()
            .overlay {
                if model.hasCover {
                    GeometryReader { proxy in
                        Line()
                            .stroke(.white.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                            .frame(height: 1)
                            .offset(y: proxy.size.height * 0.75)
                    }
                    .accessibilityHidden(true)
                }
            }
            .overlay(alignment: .topTrailing) { buttons }
            .clipShape(.rect(topLeadingRadius: isInset ? 18 : 0, topTrailingRadius: isInset ? 18 : 0))
            .pinnedWhilePulled(overscroll)
            .task { backgrounds = try? await repository.backgrounds() }
            .sheet(isPresented: $choosesBackground) {
                if let backgrounds {
                    BackgroundPickerSheet(list: backgrounds, chosen: model.pickedBackground?.id) { model.pick($0) }
                }
            }
            .onChange(of: item) {
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) { model.pick(data) }
                    self.item = nil
                }
            }
    }

    @ViewBuilder private var picture: some View {
        if let data = model.pickedCover, let image = Image(photoData: data) {
            Color.clear.overlay { image.resizable().scaledToFill() }.clipped()
        } else if let background = model.pickedBackground {
            CoverPicture(eventId: model.original?.id ?? "", images: [], fullSizeUrl: background.previewUrl,
                         theme: model.draft.theme)
        } else if model.hasCover, let original = model.original {
            CoverPicture(eventId: original.id, images: original.coverImages, fullSizeUrl: original.coverImageUrl,
                         theme: model.draft.theme)
        } else if let from = model.draft.coverFrom, let duplicate = model.duplicate {
            CoverPicture(eventId: from, images: duplicate.coverImages, fullSizeUrl: duplicate.coverImageUrl,
                         theme: model.draft.theme)
        } else {
            CoverArt(eventId: model.original?.id ?? "", theme: model.draft.theme)
        }
    }

    private var buttons: some View {
        HStack(spacing: Spacing.small) {
            if backgrounds?.enabled == true, backgrounds?.backgrounds.isEmpty == false {
                Button { choosesBackground = true } label: { Self.circle("photo.on.rectangle.angled") }
                    .accessibilityLabel("Choose a background")
            }
            PhotosPicker(selection: $item, matching: .images) {
                Self.circle("camera.fill")
            }
            .accessibilityLabel(model.hasCover ? "Change cover photo" : "Add cover photo")
            if model.hasCover {
                Button { model.removeCover() } label: { Self.circle("xmark") }
                    .accessibilityLabel("Remove cover photo")
            }
        }
        .buttonStyle(.plain)
        .padding(Spacing.large)
    }

    /// A 48 pt circle of dark glass with a white edge and a white icon,
    /// readable on a white sky and on a night photo.
    nonisolated private static func circle(_ systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(.black.opacity(0.45), in: .circle)
            .background(.ultraThinMaterial, in: .circle)
            .overlay { Circle().strokeBorder(.white.opacity(0.85), lineWidth: 1.5) }
            .contentShape(.circle)
    }
}

/// A horizontal line across its frame, for the dashed safe-area guide.
nonisolated private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

#Preview {
    VStack {
        EditorHeroView(model: EventEditorModel(event: PreviewData.event(MockEvents.rooftopId)))
        EditorHeroView(model: EventEditorModel(event: nil))
    }
    .canopyScreen()
}
