/// Every screen that can be pushed onto a tab's `NavigationStack`.
/// Screens push with `NavigationLink(value: Route.event(id))`, and each
/// stack maps a route to its view with `RouteView`. Routes carry ids, not
/// whole models, so a pushed screen always loads fresh data.
enum Route: Hashable {
    case event(Event.ID)
    case wall(Event.ID)
    /// Past events you went to (not ones you hosted).
    case pastEvents
    /// Past events you hosted.
    case pastHostedEvents
    /// Someone's list link, `/l/<code>`: join it.
    case listLink(String)
}
