//
//  AudioRepositoryImpl.swift
//  AudioApp
//
//  Created by Aamir on 11/03/2025.
//

import Foundation

final class AudioRepositoryImpl: AudioRepository {
    private let fileManager = FileManager.default
    private let audioService: AudioService
    
    init(audioService: AudioService) {
        self.audioService = audioService
    }
    
    func loadRecordings() -> [AudioNote] {
        let files = try? fileManager.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil)
        return files?.compactMap { fileURL in
            let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
            let creationDate = attributes?[.creationDate] as? Date ?? Date()
            let duration = audioService.getDuration(of: fileURL)
            return AudioNote(id: UUID(), name: fileURL.lastPathComponent, url: fileURL, date: creationDate, duration: duration, isExpanded: false, progress: 0)
        } ?? []
    }
    
    func deleteRecording(_ note: AudioNote) throws {
        try FileManager.default.removeItem(at: note.url)
    }
    
    func saveRecording(url: URL) -> [FileAttributeKey : Any]? {
        return try? fileManager.attributesOfItem(atPath: url.path)
    }
    
    func fileExists(atPath path: String) -> Bool {
        fileManager.fileExists(atPath: path)
    }
}

// MARK: Private
private extension AudioRepositoryImpl {
    func getDocumentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
