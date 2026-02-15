// Intentionally removed. This file existed temporarily during keyboard bug investigation.
// You can now delete it from the project (Remove Reference) and from disk.
// Keeping it with no compiled code ensures builds succeed until the reference is removed.

#if false
import SwiftUI
import Combine

@MainActor
final class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
}
#endif
