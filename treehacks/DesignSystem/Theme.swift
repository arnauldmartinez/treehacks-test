//
//  Theme.swift
//  treehacks
//
//  Created by Jacob Schuster on 2/14/26.
//

import SwiftUI

enum Theme {
    static let bg   = Color(white: 0.965)                    // notes-ish
    static let card = Color.white
    static let line = Color(white: 0.90)
    static let text = Color(white: 0.11)
    static let sub  = Color(white: 0.56)
    static let tint = Color(red: 0.95, green: 0.90, blue: 0.65) // subtle highlight
}

struct ThemeBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.bg.ignoresSafeArea())
    }
}

extension View {
    func themedBackground() -> some View { modifier(ThemeBackground()) }
}
