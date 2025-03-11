//
//  AudioService.swift
//  AudioApp
//
//  Created by Aamir on 11/03/2025.
//

import Foundation

protocol AudioService {
    func startRecording(name: String)
    func stopRecording() -> URL?
    func playRecording(url: URL, progressHandler: @escaping (Double) -> Void, completion: @escaping () -> Void)
    func getDuration(of url: URL) -> TimeInterval
}
