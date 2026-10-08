/// A sample event's cover: its sizes, and the hue that matches it (nil
/// for a grey photo), as the server would have worked out.
struct MockCover {
    var images: [CoverImage]
    var hue: Int?

    var isGrey: Bool { hue == nil }
}
