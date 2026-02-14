import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.tileFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.tileStroke, lineWidth: 1)
                )
                .shadow(color: Theme.tileShadow, radius: 10, x: 0, y: 6)

            content
                .padding(16)
        }
        .frame(maxWidth: .infinity)
    }
}
