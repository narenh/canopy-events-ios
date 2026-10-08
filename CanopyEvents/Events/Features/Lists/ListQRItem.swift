/// A list's name and join link, for a QR code (one of yours, or one on an
/// event).
struct ListQRItem: Hashable, Identifiable {
    var id: String
    var name: String
    var url: String

    /// The link without `https://`, to read out at the door.
    var shortURL: String {
        url.replacing(/^https?:\/\//, with: "")
    }
}

extension ListQRItem {
    init(_ list: OwnedList) {
        self.init(id: list.id, name: list.name, url: list.url)
    }

    init(_ list: HostList) {
        self.init(id: list.id, name: list.name, url: list.url)
    }
}
