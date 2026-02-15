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

    private func submit() {
        error = nil
        let p1 = pass1.trimmingCharacters(in: .whitespacesAndNewlines)
        let p2 = pass2.trimmingCharacters(in: .whitespacesAndNewlines)

        guard p1.count >= 4 else { error = "Use at least 4 digits."; return }
        guard p1 == p2 else { error = "Passcodes do not match."; return }

        appState.setPasscode(p1)
    }

    #if os(iOS)
    private let submitLabel: SubmitLabel = .done
    #else
    private let submitLabel: SubmitLabel = .return
    #endif

    private func filterDigits(_ text: String, limit: Int? = nil) -> String {
        let digits = text.filter { $0.isNumber }
        if let limit { return String(digits.prefix(limit)) }
        return digits
    }

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case pass1
        case pass2
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quick info")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("If you are in immediate danger, call emergency services. This app is not a replacement for 911.")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.sub)
                }

                AppCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Set a passcode")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.text)

                        SecureField("Passcode", text: Binding(
                            get: { pass1 },
                            set: { pass1 = filterDigits($0, limit: 8) }
                        ))
                        #if os(iOS)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                        #endif
                            .textFieldStyle(.plain)
                            .submitLabel(submitLabel)
                            .onSubmit { submit() }
                            .focused($focusedField, equals: .pass1)

                        Rectangle().fill(Theme.line).frame(height: 1)

                        SecureField("Confirm passcode", text: Binding(
                            get: { pass2 },
                            set: { pass2 = filterDigits($0, limit: 8) }
                        ))
                        #if os(iOS)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                        #endif
                            .textFieldStyle(.plain)
                            .submitLabel(submitLabel)
                            .onSubmit { submit() }
                            .focused($focusedField, equals: .pass2)
                    }
                }
                .frame(maxWidth: .infinity)

                if let error {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(.red)
                }

                Button(action: submit) {
                    Text("Continue")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .disabled(pass1.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 || pass1 != pass2)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        .onChange(of: pass1) { _ in
            let p1 = pass1.trimmingCharacters(in: .whitespacesAndNewlines)
            let p2 = pass2.trimmingCharacters(in: .whitespacesAndNewlines)
            if p1.count >= 4 && p1 == p2 { submit() }
        }
        .onChange(of: pass2) { _ in
            let p1 = pass1.trimmingCharacters(in: .whitespacesAndNewlines)
            let p2 = pass2.trimmingCharacters(in: .whitespacesAndNewlines)
            if p1.count >= 4 && p1 == p2 { submit() }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .themedBackground()
    }
}

