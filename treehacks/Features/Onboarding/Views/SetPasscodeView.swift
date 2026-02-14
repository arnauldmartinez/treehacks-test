//
//  SetPasscodeView.swift
//  treehacks
//
//  Created by Jacob Schuster on 2/14/26.
//

import SwiftUI

struct SetPasscodeView: View {
    @EnvironmentObject private var appState: AppState

    @State private var pass1 = ""
    @State private var pass2 = ""
    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick info")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.text)

            Text("If you are in immediate danger, call emergency services. This app is not a replacement for 911.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.sub)

            AppCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Set a passcode")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)

                    SecureField("Passcode", text: $pass1)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        #endif
                        .textFieldStyle(.plain)

                    Rectangle().fill(Theme.line).frame(height: 1)

                    SecureField("Confirm passcode", text: $pass2)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        #endif
                        .textFieldStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)

            if let error {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
            }

            Button {
                error = nil
                let p1 = pass1.trimmingCharacters(in: .whitespacesAndNewlines)
                let p2 = pass2.trimmingCharacters(in: .whitespacesAndNewlines)

                guard p1.count >= 4 else { error = "Use at least 4 digits."; return }
                guard p1 == p2 else { error = "Passcodes do not match."; return }

                appState.setPasscode(p1)
            } label: {
                Text("Continue")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)

            Spacer()
        }
        .padding(18)
        .themedBackground()
    }
}
