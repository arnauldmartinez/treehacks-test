import SwiftUI

@main
struct TreehacksApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var incidentsStore = IncidentsStore()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
                .environmentObject(incidentsStore)
        }
    }
}
