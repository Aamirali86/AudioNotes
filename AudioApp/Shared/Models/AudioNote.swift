//
//  AudioNote.swift
//  AudioApp
//
//  Created by Aamir on 11/03/2025.
//

import Foundation

struct AudioNote: Identifiable {
    let id: UUID
    let name: String
    let url: URL
    let date: Date
    let duration: TimeInterval
    var isExpanded: Bool
    var progress: Double
}

// MARK: Formatter
extension AudioNote {
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
