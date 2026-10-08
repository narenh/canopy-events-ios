import SwiftUI

/// The editable form inside `ProfileView`. Make a new one (with a new
/// model) whenever your saved profile changes.
struct ProfileForm: View {
    @Environment(AppSession.self) private var session
    @State var model: ProfileModel

    var body: some View {
        Form {
            Section {
                if let profile = session.profile { ProfileHeader(profile: profile) }
            }
            .listRowBackground(Color.clear)

            Section("Name") {
                TextField("First name", text: $model.draft.firstName)
                    .textContentType(.givenName)
                TextField("Last name", text: $model.draft.lastName)
                    .textContentType(.familyName)
            }
            .glassRowBackground()

            Section {
                TextField("Phone", text: $model.draft.phone)
                    .textContentType(.telephoneNumber)
                TextField("Instagram", text: $model.draft.instagram)
                TextField("Venmo", text: $model.draft.venmo)
                TextField("Cash App", text: $model.draft.cashapp)
            } header: {
                Text("Contact (only you see these)")
            }
            .glassRowBackground()

            Section {
                Toggle("Let people who know your phone or Instagram find you", isOn: $model.draft.findable)
            }
            .glassRowBackground()

            ProfileSettingsSections()

            // Always shown while the app is in development. Gate it before
            // the App Store, not before.
            ProfileDebugSection()
                .glassRowBackground()

            Section {
                Button("Sign out", role: .destructive) {
                    Task { await session.signOut() }
                }
            }
            .glassRowBackground()
        }
        .navigationTitle("Profile")
        .toolbar {
            if model.hasChanges {
                Button("Save", role: .confirm) { Task { await model.save(using: session) } }
                    .disabled(!model.draft.isValid || model.isSaving)
            }
        }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }
}

#Preview {
    NavigationStack { ProfileForm(model: ProfileModel(profile: MockPeople.maya)) }
        .mockEnvironment()
}
