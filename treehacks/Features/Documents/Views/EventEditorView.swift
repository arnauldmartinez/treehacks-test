//
//  EventEditorView.swift
//  treehacks
//
//  Created by Arnauld Martinez on 2/14/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct EventEditorView: View {

    let eventID: UUID
    @EnvironmentObject private var vm: SecureEventsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = AudioRecorder()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showImageSourceDialog = false
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var showCameraUnavailableAlert = false
    @FocusState private var bodyFocused: Bool
    @StateObject private var audioPlayer = AudioPlayer()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Spacer(minLength: 60)

                AppCard {
                    VStack(alignment: .leading, spacing: 12) {

                        TextField(
                            "Title",
                            text: vm.bindingTitle(for: eventID)
                        )
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.text)
                        .textFieldStyle(.plain)

                        Rectangle()
                            .fill(Theme.line)
                            .frame(height: 1)

                        TextEditor(
                            text: vm.bindingBody(for: eventID)
                        )
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 300)
                        .focused($bodyFocused)

                        // Attachments display
                        if let event = vm.events.first(where: { $0.id == eventID }) {
                            if !event.photoFileNames.isEmpty {
                                Text("Photos")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.sub)
                                    .padding(.top, 8)

                                ScrollView(.horizontal, showsIndicators: true) {
                                    HStack(spacing: 12) {
                                        ForEach(event.photoFileNames, id: \.self) { name in
                                            let url = vm.urlForAttachment(named: name)
                                            if let data = try? Data(contentsOf: url), let uiImg = UIImage(data: data) {
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
                                                            vm.removePhoto(named: name, from: eventID)
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
                                                            vm.removePhoto(named: name, from: eventID)
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

                            if !event.audioFileNames.isEmpty {
                                Text("Audio")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.sub)
                                    .padding(.top, 8)

                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(event.audioFileNames.enumerated()), id: \.element) { idx, name in
                                        HStack {
                                            Button {
                                                let url = vm.urlForAttachment(named: name)
                                                audioPlayer.play(url: url, id: name)
                                            } label: {
                                                Label(audioPlayer.isPlaying && audioPlayer.currentID == name ? "Stop" : "Play", systemImage: audioPlayer.isPlaying && audioPlayer.currentID == name ? "stop.circle.fill" : "play.fill")
                                            }

                                            Spacer()

                                            Button(role: .destructive) {
                                                vm.removeAudio(named: name, from: eventID)
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
                                            vm.addAudio(data, to: eventID)
                                        }
                                    } else {
                                        Task {
                                            let granted = await recorder.requestPermission()
                                            if granted {
                                                try? recorder.start()
                                            }
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
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.deleteEvent(eventID)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
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
                vm.addPhoto(data, to: eventID)
            }
        }
        .sheet(isPresented: $showLibraryPicker) {
            ImagePicker(sourceType: .photoLibrary) { data in
                vm.addPhoto(data, to: eventID)
            }
        }
        .alert("Camera Unavailable", isPresented: $showCameraUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Camera is not available in the simulator. Please test on a real device.")
        }
    }
}

