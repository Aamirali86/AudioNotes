//
//  AudioView.swift
//  AudioApp
//
//  Created by Aamir on 10/03/2025.
//

import SwiftUI
import AVFoundation

struct AudioView: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.recordings) { note in
                    AudioItemView(viewModel: viewModel, note: note)
                }
                .scrollIndicators(.hidden)
                .padding(.bottom, 80)
            }
            .navigationTitle("Audio Notes")
            .overlay(alignment: .bottom) {
                bottomSheet
            }
            .overlay {
                if viewModel.recordings.isEmpty {
                    Text("No recordings found")
                }
            }
        }
    }
}

// MARK: Components
private extension AudioView {
    var bottomSheet: some View {
        VStack {
            if viewModel.isRecording {
                Text(viewModel.recordingName)
                    .font(.headline)
                Text(viewModel.recordingDuration)
                    .font(.subheadline)
            }
            
            Button(action: {
                viewModel.toggleRecordingSubject.send()
            }) {
                Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    AudioView(viewModel: AudioViewModel(audioService: AudioServiceImpl(), repository: AudioRepositoryImpl(audioService: AudioServiceImpl())))
}
