import SwiftUI
import UIKit
import AVFoundation
import Combine
import PhotosUI

struct NewEventView: View {

    let onSubmit: (String, String, [Data], [Data]) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var bodyText: String = ""

    @State private var photoDatas: [Data] = []
    @State private var showImageSourceDialog = false
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var showCameraUnavailableAlert = false

    @StateObject private var recorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var audioDatas: [Data] = []
    @FocusState private var bodyFocused: Bool

    var body: some View {
        VStack {

            ScrollView {
                VStack(spacing: 24) {

                    Spacer(minLength: 60)

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {

                            ZStack(alignment: .leading) {
                                if title.isEmpty {
                                    Text("Event Title")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(Theme.text)
                                }
                                TextField("", text: $title)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                    .textFieldStyle(.plain)
                                    .tint(Theme.text)
                            }

                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)

                            TextEditor(text: $bodyText)
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.text)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 300)
                                .focused($bodyFocused)

                            if !photoDatas.isEmpty {
                                Text("Photos")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.sub)
                                    .padding(.top, 8)

                                ScrollView(.horizontal, showsIndicators: true) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(photoDatas.enumerated()), id: \.offset) { idx, data in
                                            if let uiImg = UIImage(data: data) {
                                                Image(uiImage: uiImg)
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fill)
                                                    .frame(width: 120, height: 120)
                                                    .clipped()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Theme.tileStroke, lineWidth: 1)
                                                    )
                                                    .cornerRadius(10)
                                                    .overlay(alignment: .topTrailing) {
                                                        Button {
                                                            photoDatas.remove(at: idx)
                                                        } label: {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.system(size: 16, weight: .bold))
                                                                .foregroundStyle(Theme.accent)
                                                        }
                                                        .offset(x: -6, y: 6)
                                                    }
                                            } else {
                                                Rectangle()
                                                    .fill(Theme.tileFill)
                                                    .frame(width: 120, height: 120)
                                                    .overlay(Image(systemName: "photo").foregroundStyle(Theme.sub))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Theme.tileStroke, lineWidth: 1)
                                                    )
                                                    .cornerRadius(10)
                                                    .overlay(alignment: .topTrailing) {
                                                        Button {
                                                            photoDatas.remove(at: idx)
                                                        } label: {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.system(size: 16, weight: .bold))
                                                                .foregroundStyle(Theme.accent)
                                                        }
                                                        .offset(x: -6, y: 6)
                                                    }
                                            }
                                        }
                                    }
                                }
                                .frame(height: 130)
                            }

                            if !audioDatas.isEmpty {
                                Text("Audio")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.sub)
                                    .padding(.top, 8)

                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(audioDatas.enumerated()), id: \.offset) { idx, data in
                                        HStack {
                                            Button {
                                                audioPlayer.play(data: data, id: "temp_\(idx)")
                                            } label: {
                                                Label(audioPlayer.isPlaying && audioPlayer.currentID == "temp_\(idx)" ? "Stop" : "Play", systemImage: audioPlayer.isPlaying && audioPlayer.currentID == "temp_\(idx)" ? "stop.circle.fill" : "play.fill")
                                            }

                                            Spacer()

                                            Button(role: .destructive) {
                                                audioDatas.remove(at: idx)
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                        }
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.sub)
                                    }
                                }
                            }
                            
                            VStack(spacing: 14) {
                                Button {
                                    showImageSourceDialog = true
                                } label: {
                                    Text("+ Add Image")
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.accent)

                                Button {
                                    if recorder.isRecording {
                                        if let data = recorder.stop() {
                                            audioDatas.append(data)
                                        }
                                    } else {
                                        Task {
                                            let granted = await recorder.requestPermission()
                                            if granted { try? recorder.start() }
                                        }
                                    }
                                } label: {
                                    Text(recorder.isRecording ? "Stop Recording" : "+ Add Audio")
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(recorder.isRecording ? .red : Theme.accent)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 165)

                    Spacer(minLength: 60)
                }
            }
            .themedBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSubmit(title, bodyText, photoDatas, audioDatas)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .sheet(isPresented: $showImageSourceDialog) {
                VStack(spacing: 16) {
                    Text("Add Image")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showImageSourceDialog = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showCameraPicker = true
                            }
                        } else {
                            showImageSourceDialog = false
                            showCameraUnavailableAlert = true
                        }
                    } label: {
                        Text("Take Photo")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Theme.bgBase)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.text)

                    Button {
                        showImageSourceDialog = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showLibraryPicker = true
                        }
                    } label: {
                        Text("Choose from Library")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Theme.bgBase)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.text)
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.bgBase)
            }
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(sourceType: .camera) { data in
                    photoDatas.append(data)
                }
            }
            .sheet(isPresented: $showLibraryPicker) {
                ImagePicker(sourceType: .photoLibrary) { data in
                    photoDatas.append(data)
                }
            }
            .alert("Camera Unavailable", isPresented: $showCameraUnavailableAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Camera is not available in the simulator. Please test on a real device.")
            }
        }
    }
}

