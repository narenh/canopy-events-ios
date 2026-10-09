/// Which of your lists has its sheet open, and whether it opens on its
/// QR code (a list just made).
struct OpenedList: Identifiable, Hashable {
    var id: OwnedList.ID
    var showsQR = false
}
