//
//  AudioServiceImpl.swift
//  AudioApp
//
//  Created by Aamir on 11/03/2025.
//

import AVFoundation

final class AudioServiceImpl: AudioService {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    init() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            AVAudioApplication.requestRecordPermission { _ in }
        } catch {}
    }
    
    func startRecording(name: String) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(name)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            audioRecorder?.stop()
            audioRecorder = nil
        }
    }
    
    func stopRecording() -> URL? {
        guard let recorder = audioRecorder else { return nil }
        let recordedURL = recorder.url
        recorder.stop()
        audioRecorder = nil
        return recordedURL
    }
    
    func playRecording(url: URL, progressHandler: @escaping (Double) -> Void, completion: @escaping () -> Void) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let player = self?.audioPlayer else { return }
                progressHandler(player.currentTime / player.duration)
                if player.currentTime >= player.duration {
                    self?.timer?.invalidate()
                    completion()
                }
            }
        } catch {
            print("Playback failed: \(error.localizedDescription)")
        }
    }
    
    func getDuration(of url: URL) -> TimeInterval {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            return audioPlayer.duration
        } catch {
            print("Failed to get duration: \(error.localizedDescription)")
            return 0
        }
    }
}

// MARK: Private
private extension AudioServiceImpl {
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
