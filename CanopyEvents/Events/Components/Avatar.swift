import SwiftUI

/// A person's round photo, with their initials while it loads or when
/// they have none.
struct Avatar: View {
    let person: Person
    var size: CGFloat = 40

    var body: some View {
        AsyncImage(url: person.photoUrl) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            initials
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
        .overlay { Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1) }
        .accessibilityLabel(person.fullName)
    }

    private var initials: some View {
        Text(person.initials)
            .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
            .foregroundStyle(Palette.muted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.glowBright)
    }
}

#Preview {
    HStack {
        Avatar(person: MockPeople.ana, size: 64)
        Avatar(person: MockPeople.chloe, size: 64)
        Avatar(person: MockPeople.chloe)
    }
    .padding()
    .preferredColorScheme(.dark)
}
