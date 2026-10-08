import SwiftUI

/// A few overlapping avatars, then "+N" for the rest.
struct AvatarStack: View {
    let people: [Person]
    var size: CGFloat = 32
    var maxShown = 5

    var body: some View {
        HStack(spacing: -size * 0.3) {
            ForEach(people.prefix(maxShown)) { person in
                Avatar(person: person, size: size)
            }
            if people.count > maxShown {
                Text("+\(people.count - maxShown)")
                    .font(.caption.weight(.semibold))
                    .frame(width: size, height: size)
                    .background(Palette.glow, in: .circle)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.large) {
        AvatarStack(people: Array(MockPeople.everyone.prefix(3)))
        AvatarStack(people: MockPeople.everyone)
    }
    .padding()
    .preferredColorScheme(.dark)
}
