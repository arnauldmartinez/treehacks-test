import SwiftUI

struct ForumsPlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForumTile(title: "Lawyer", description: "Contact the best lawyers nearby.")
                ForumTile(title: "Support", description: "Connect with people who have fought similar battles and won.")
                ForumTile(title: "Babysitter", description: "Book a babysitter to keep your children safe.")
            }
            .padding(.horizontal, 18)
            .padding(.top, 90)
            .padding(.bottom, 60)
        }
        .themedBackground()
        .navigationTitle("Forums")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ForumTile: View {
    let title: String
    let description: String

    var body: some View {
        AppCard {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.text)

                    Text(description)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.sub)
                }
                Spacer(minLength: 8)
                Text(">")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.sub)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    NavigationStack { ForumsPlaceholderView() }
}
