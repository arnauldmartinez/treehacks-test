//
//  SecureHomeView.swift
//  treehacks
//
//  Created by Jacob Schuster on 2/14/26.
//

import SwiftUI

struct SecureHomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Secure")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.text)

                AppCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Basic secure page")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.text)
                        Text("Next: tiles for Documents / AI Agent / Forum / Emergency / Chats.")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.sub)
                    }
                }

                Spacer()
            }
            .padding(18)
            .themedBackground()
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Lock") { appState.lockToDecoy() }
                }
            }
        }
    }
}
