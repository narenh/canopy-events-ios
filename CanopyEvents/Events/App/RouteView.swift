import SwiftUI

/// The view for a `Route`. Each tab's stack uses it in
/// `.navigationDestination(for: Route.self) { RouteView(route: $0) }`.
/// To add a pushable screen, add a case to `Route` and a line here.
struct RouteView: View {
    let route: Route

    var body: some View {
        destination
            .verifyEmailBanner()
    }

    @ViewBuilder private var destination: some View {
        switch route {
        case .event(let id): EventDetailView(eventId: id)
        case .guestList(let id): GuestListView(eventId: id)
        case .wall(let id): WallView(eventId: id)
        case .pastEvents: PastEventsView(showsHosted: false)
        case .pastHostedEvents: PastEventsView(showsHosted: true)
        case .declinedEvents: DeclinedEventsView()
        }
    }
}

#Preview {
    NavigationStack {
        RouteView(route: .declinedEvents)
    }
    .mockEnvironment()
}
