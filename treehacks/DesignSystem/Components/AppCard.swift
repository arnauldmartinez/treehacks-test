//
//  AppCard.swift
//  treehacks
//
//  Created by Jacob Schuster on 2/14/26.
//

import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Theme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Theme.line, lineWidth: 1)
            )
            .overlay(content.padding(14), alignment: .topLeading)
    }
}
