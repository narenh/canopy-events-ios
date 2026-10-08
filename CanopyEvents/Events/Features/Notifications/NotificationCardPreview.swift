import SwiftUI

/// The expanded notification's card inside the app, at a notification's
/// width, for looking at (Profile's Debug section). Its buttons show the
/// answered state but answer nothing.
struct NotificationCardPreview: View {
    let card: NotificationCard
    @State private var answered: String?

    var body: some View {
        ScrollView {
            NotificationCardView(card: card, answered: answered) { action in
                withAnimation { answered = action }
            }
            .clipShape(.rect(cornerRadius: Radius.large))
            .frame(maxWidth: 400)
            .padding(Spacing.large)
        }
        .presentationDetents([.large])
    }
}
