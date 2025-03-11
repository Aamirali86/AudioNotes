//
//  AudioItemView.swift
//  AudioApp
//
//  Created by Aamir on 12/03/2025.
//

import SwiftUI

struct AudioItemView: View {
    let viewModel: AudioViewModel
    let note: AudioNote
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(note.name)
                        .font(.headline)
                    Text((note.dateFormatted))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(note.durationFormatted)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.toggleExpandSubject.send(note)
            }
            
            if note.isExpanded {
                VStack {
                    ProgressView(value: note.progress)
                        .progressViewStyle(.linear)
                    
                    HStack {
                        Button {
                            viewModel.playRecordingSubject.send(note)
                        } label: {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.borderless)
                        .padding(8)
                        .clipped()
                        Spacer()
                        Button {
                            viewModel.deleteRecordingSubject.send(note)
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.borderless)
                        .padding(8)
                        .clipped()
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
