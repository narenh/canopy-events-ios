import Intents
import UserNotifications

/// Turns a notification into a communication notification: the sender's
/// name and photo on it, Messages-style. Donates an incoming
/// `INSendMessageIntent` with the sender as an `INPerson` (with their
/// picture) and updates the content from it. Local notifications use it
/// now; a real push will need a Notification Service Extension to fetch
/// the sender's photo and call this (ARCHITECTURE.md).
///
/// Needs the Communication Notifications capability
/// (`com.apple.developer.usernotifications.communication`) and
/// `INSendMessageIntent` in `NSUserActivityTypes`. Without them the
/// system leaves the notification as it was.
enum CommunicationNotificationBuilder {
    /// The content with `sender` on it, or `content` unchanged if the
    /// system won't make it a communication notification.
    static func content(
        _ content: UNMutableNotificationContent, from sender: Person, avatar: Data?
    ) async -> UNNotificationContent {
        let image = avatar.map { INImage(imageData: $0) }
        var name = PersonNameComponents()
        name.givenName = sender.firstName
        name.familyName = sender.lastName
        let person = INPerson(
            personHandle: INPersonHandle(value: sender.id, type: .unknown),
            nameComponents: name, displayName: sender.fullName, image: image,
            contactIdentifier: nil, customIdentifier: sender.id
        )
        let intent = INSendMessageIntent(
            recipients: nil, outgoingMessageType: .outgoingMessageText, content: content.body,
            speakableGroupName: nil, conversationIdentifier: content.threadIdentifier,
            serviceName: nil, sender: person, attachments: nil
        )
        #if !os(macOS)
        // The Mac has no such call; the picture still rides on the INPerson.
        intent.setImage(image, forParameterNamed: \.sender)
        #endif
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        try? await interaction.donate()
        return (try? content.updating(from: intent)) ?? content
    }
}
