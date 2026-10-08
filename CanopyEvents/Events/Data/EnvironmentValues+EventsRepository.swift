import SwiftUI

extension EnvironmentValues {
    /// The repository every screen reads from. `RootView` sets the signed-in
    /// person's repository; previews get a mock signed in as Maya.
    @Entry var eventsRepository: any EventsRepository = MockEventsRepository()
}
