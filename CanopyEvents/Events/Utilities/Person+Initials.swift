extension Person {
    /// "AL" for Ana Lima, shown when there's no photo.
    var initials: String {
        PersonName.initials(firstName: firstName, lastName: lastName)
    }
}
