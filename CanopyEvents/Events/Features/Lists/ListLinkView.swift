import SwiftUI

/// What a list's link (`/l/<code>`) opens, the web's `listLinkPage`:
/// "Join Ana's Drag Race?", "Ana will be able to invite you to events."
/// and Join; then "You're on Ana's Drag Race", with how many events that
/// invited you to. Your own list, or one you're on, says so instead.
struct ListLinkView: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @State private var model: ListLinkModel

    init(code: String) {
        _model = State(initialValue: ListLinkModel(code: code))
    }

    var body: some View {
        Group {
            if model.isNotFound {
                ContentUnavailableView(
                    "This link doesn't work", systemImage: "link",
                    description: Text("It may have been reset. Ask for a new one.")
                )
            } else if let link = model.link {
                ScrollView {
                    card(for: link)
                        .frame(maxWidth: 520)
                        .padding(Spacing.large)
                        .frame(maxWidth: .infinity)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(model.link.map { "Join \($0.list.name)" } ?? "")
        .inlineNavigationTitle()
        .task { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }

    private func card(for link: ListLinkOwner) -> some View {
        VStack(spacing: Spacing.large) {
            Avatar(person: link.owner, size: 88)
            VStack(spacing: Spacing.small) {
                Text(heading(for: link))
                    .font(Typography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)
                if let line = line(for: link) {
                    Text(line)
                        .foregroundStyle(Palette.muted)
                }
            }
            .multilineTextAlignment(.center)
            if model.joined == nil, link.viewer?.isOwner != true, link.viewer?.isMember != true {
                Button {
                    Task { await join() }
                } label: {
                    Text("Join")
                        .font(Typography.button)
                        .frame(maxWidth: .infinity)
                }
                .accentProminentButtonStyle()
                .controlSize(.large)
                .disabled(model.isJoining)
            }
        }
        .padding(.vertical, Spacing.small)
        .frame(maxWidth: .infinity)
        .glassCard()
    }

    private func heading(for link: ListLinkOwner) -> String {
        let first = model.ownerFirst, list = link.list.name
        if link.viewer?.isOwner == true { return "This is your list" }
        if model.joined != nil || link.viewer?.isMember == true { return "You're on \(first)'s \(list)" }
        return "Join \(first)'s \(list)?"
    }

    private func line(for link: ListLinkOwner) -> String? {
        let first = model.ownerFirst
        if link.viewer?.isOwner == true { return link.list.name }
        if let joined = model.joined {
            switch joined.invitedTo {
            case 0: return nil
            case 1: return "\(first) invited you to 1 event."
            default: return "\(first) invited you to \(joined.invitedTo) events."
            }
        }
        if link.viewer?.isMember == true { return nil }
        return "\(first) will be able to invite you to events."
    }

    private func join() async {
        await model.join(using: repository)
        if model.joined != nil {
            AccessibilityNotification.Announcement(heading(for: model.link!)).post()
            session.dataChanged()
        }
    }
}

#Preview("Ana's Dumpling crew") {
    NavigationStack { ListLinkView(code: MockLists.dumplingCrewCode) }
        .mockEnvironment()
}

#Preview("Your own") {
    NavigationStack { ListLinkView(code: "9xQ2mPc7LtRe") }
        .mockEnvironment()
}

#Preview("Wrong code") {
    NavigationStack { ListLinkView(code: "nope00000000") }
        .mockEnvironment()
}
