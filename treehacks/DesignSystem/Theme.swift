import SwiftUI

// Palette sampled from your image:
// #e9d9f5, #c7a9d7, #a886be, #8b69a9, #5d4285, #3e2661

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xff) / 255.0
        let g = Double((hex >> 8)  & 0xff) / 255.0
        let b = Double(hex & 0xff) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

enum Theme {
    // Background
    static let bgBase      = Color(hex: 0xE9D9F5)
    static let bgOverlay1  = Color(hex: 0xE9D9F5, alpha: 0.45)
    static let bgOverlay2  = Color(hex: 0x3E2661, alpha: 0.20)

    // Text
    static let text        = Color(hex: 0x2B1744)           // deep purple
    static let sub         = Color(hex: 0x5D4285)

    // Accent / UI
    static let accent      = Color(hex: 0xC7A9D7)
    static let line        = Color(hex: 0xA886BE, alpha: 0.35)

    // Tiles
    static let tileFill    = Color(hex: 0xE9D9F5, alpha: 0.70)
    static let tileStroke  = Color(hex: 0x8B69A9, alpha: 0.45)
    static let tileShadow  = Color(hex: 0x3E2661, alpha: 0.22)
}

struct ThemedBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Image("background_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Soft overlay so text stays readable
            LinearGradient(
                colors: [Theme.bgOverlay1, Theme.bgOverlay2],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func themedBackground() -> some View { modifier(ThemedBackground()) }
}
