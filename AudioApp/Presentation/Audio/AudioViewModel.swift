//
//  AudioViewModel.swift
//  AudioApp
//
//  Created by Aamir on 11/03/2025.
//

import Combine
import Foundation
import SwiftUI

final class AudioViewModel: ObservableObject {
    // Input
    let toggleExpandSubject = PassthroughSubject<AudioNote, Never>()
    let toggleRecordingSubject = PassthroughSubject<Void, Never>()
    let playRecordingSubject = PassthroughSubject<AudioNote, Never>()
    let deleteRecordingSubject = PassthroughSubject<AudioNote, Never>()

    // Output
    @Published var recordings: [AudioNote] = []
    @Published var isRecording = false
    @Published var recordingName: String = ""
    @Published var recordingDuration: String = ""

    private var timer: Timer?
    private let audioService: AudioService
    private let repository: AudioRepository
    private let recordingDurationSubject = CurrentValueSubject<TimeInterval, Never>(0)
    private var cancellables = Set<AnyCancellable>()
    
    init(audioService: AudioService, repository: AudioRepository) {
        self.audioService = audioService
        self.repository = repository
        loadRecordings()
        bindSelf()
    }
}

// MARK: Binding
private extension AudioViewModel {
    func bindSelf() {
        toggleExpandSubject
            .sink { [weak self] note in
                self?.toggleExpand(note)
            }
            .store(in: &cancellables)
        
        toggleRecordingSubject
            .sink { [weak self] _ in
                self?.toggleRecording()
            }
            .store(in: &cancellables)
        
        playRecordingSubject
            .sink { [weak self] note in
                self?.playRecording(note)
            }
            .store(in: &cancellables)
        
        deleteRecordingSubject
            .sink { [weak self] note in
                self?.deleteRecording(note)
            }
            .store(in: &cancellables)
        
        recordingDurationSubject
            .map { duration in
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                return String(format: "%02d:%02d", minutes, seconds)
            }
            .assign(to: &$recordingDuration)
    }
}

// MARK: Timer
private extension AudioViewModel {
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let duration = self?.recordingDurationSubject.value else { return }
            self?.recordingDurationSubject.send(duration + 1)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: Recordings
private extension AudioViewModel {
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        let counter = recordings.count + 1
        recordingName = "New Recording (\(counter))"
        isRecording = true
        recordingDurationSubject.send(0)
        startTimer()
        audioService.startRecording(name: recordingName)
    }
    
    func stopRecording() {
        if let url = audioService.stopRecording() {
            let attributes = repository.saveRecording(url: url)
            let creationDate = attributes?[.creationDate] as? Date ?? Date()
            let duration = audioService.getDuration(of: url)
            let newNote = AudioNote(id: UUID(), name: url.lastPathComponent, url: url, date: creationDate, duration: duration, isExpanded: false, progress: 0)
            recordings.insert(newNote, at: 0)
        }
        isRecording = false
        stopTimer()
    }
    
    func playRecording(_ note: AudioNote) {
        guard repository.fileExists(atPath: note.url.path) else {
            print("File does not exist: \(note.url.path)")
            return
        }
        
        audioService.playRecording(url: note.url, progressHandler: { [unowned self] progress in
            if let index = recordings.firstIndex(where: { $0.id == note.id }) {
                DispatchQueue.main.async {
                    self.recordings[index].progress = progress
                }
            }
        }, completion: { [unowned self] in
            if let index = recordings.firstIndex(where: { $0.id == note.id }) {
                DispatchQueue.main.async {
                    self.recordings[index].progress = 0.0
                }
            }
        })
    }
    
    func deleteRecording(_ note: AudioNote) {
        do {
            try repository.deleteRecording(note)
            DispatchQueue.main.async {
                self.recordings.removeAll { $0.id == note.id }
            }
        } catch {
            print("Failed to delete recording: \(error.localizedDescription)")
        }
    }
    
    func toggleExpand(_ note: AudioNote) {
        if let index = recordings.firstIndex(where: { $0.id == note.id }) {
            recordings[index].isExpanded.toggle()
        }
    }
    
    func loadRecordings() {
        recordings = repository
            .loadRecordings()
            .sorted { $0.date > $1.date }
    }
}
