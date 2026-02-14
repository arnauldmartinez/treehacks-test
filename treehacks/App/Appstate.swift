import SwiftUI
import Combine
import CryptoKit

@MainActor
final class AppState: ObservableObject {
    enum Route: Equatable {
        case onboarding
        case decoy
        case secure
    }

    @Published var route: Route

    private let passcodeKey = "passcodeHash_v1"

    init() {
        let has = !(UserDefaults.standard.string(forKey: passcodeKey) ?? "").isEmpty
        self.route = has ? .decoy : .onboarding
    }

    func setPasscode(_ passcode: String) {
        let h = Self.sha256Hex(passcode)
        UserDefaults.standard.set(h, forKey: passcodeKey)
        route = .decoy
    }

    func verifyPasscode(_ attempt: String) -> Bool {
        let stored = UserDefaults.standard.string(forKey: passcodeKey) ?? ""
        guard !stored.isEmpty else { return false }
        return Self.sha256Hex(attempt) == stored
    }

    func unlockSecure() { route = .secure }
    func lockToDecoy()  { route = .decoy }

    private static func sha256Hex(_ s: String) -> String {
        let data = Data(s.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
