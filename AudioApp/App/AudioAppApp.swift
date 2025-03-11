//
//  AudioAppApp.swift
//  AudioApp
//
//  Created by Aamir on 10/03/2025.
//

import SwiftUI

@main
struct AudioAppApp: App {
    var body: some Scene {
        WindowGroup {
            let audioService = AudioServiceImpl()
            let audioViewModel = AudioViewModel(audioService: audioService, repository: AudioRepositoryImpl(audioService: audioService))
            AudioView(viewModel: audioViewModel)
        }
    }
}
