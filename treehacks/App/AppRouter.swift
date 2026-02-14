import SwiftUI

struct AppRouter: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        switch appState.route {
        case .onboarding:
            SetPasscodeView()
        case .decoy:
            DecoyNotesListView()
        case .secure:
            SecureHomeView()
        }
    }
}
