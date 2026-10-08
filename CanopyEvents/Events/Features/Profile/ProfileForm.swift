import SwiftUI

/// The editable form inside `ProfileView`. Make a new one (with a new
/// model) whenever your saved profile changes.
struct ProfileForm: View {
    @Environment(AppSession.self) private var session
    @State var model: ProfileModel

    var body: some View {
        Form {
            Section {
                if let me = session.me { ProfileHeader(me: me) }
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
                Text("Contact")
            } footer: {
                Text("Only you see these. Canopy never shows your contact details to anyone else.")
            }
            .glassRowBackground()

            Section {
                Toggle("Let people who know your phone or Instagram find you", isOn: $model.draft.findable)
            } footer: {
                Text("Hosts who already have your number or handle can invite you. Nobody can browse or search for you.")
            }
            .glassRowBackground()

            if session.showsDebugTools {
                ProfileDebugSection()
                    .glassRowBackground()
            }

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
    NavigationStack { ProfileForm(model: ProfileModel(me: MockPeople.maya)) }
        .mockEnvironment()
}
