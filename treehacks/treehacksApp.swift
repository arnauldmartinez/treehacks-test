//
//  treehacksApp.swift
//  treehacks
//
//  Created by Arnauld Martinez on 2/13/26.
//

import SwiftUI

@main
struct TreehacksApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
        }
    }
}
