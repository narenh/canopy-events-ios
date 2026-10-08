import SwiftUI

/// Who's hosting: the creator first, then any co-hosts.
struct HostsSection: View {
    let hosts: [Host]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: hosts.count == 1 ? "Host" : "Hosts")
            ForEach(hosts) { host in
                PersonRow(person: host.person, detail: host.role.title)
            }
        }
        .glassCard()
    }
}

#Preview {
    HostsSection(hosts: PreviewData.event(MockEvents.birthdayId).hosts)
        .padding()
        .canopyScreen()
        .preferredColorScheme(.dark)
}
