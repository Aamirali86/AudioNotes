//
//  AudioRepository.swift
//  AudioApp
//
//  Created by Aamir on 12/03/2025.
//

import Foundation

protocol AudioRepository {
    func loadRecordings() -> [AudioNote]
    func deleteRecording(_ note: AudioNote) throws
    func saveRecording(url: URL) -> [FileAttributeKey : Any]?
    func fileExists(atPath: String) -> Bool
}
