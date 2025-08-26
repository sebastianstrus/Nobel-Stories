//
//  AudioManager.swift
//  Nobel Stories
//
//  Created by Sebastian Strus on 8/26/25.
//

import Foundation
import AVFoundation

final class AudioManager {
    // Shared instance for easy access
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?
    
    // Private initializer to ensure a single instance
    private init() {}
    
    // Function to play a sound file
    func playSound(storyId: String) {
        // Construct the filename from the story ID
        let filename = "\(storyId).mp3"
        
        // Find the URL for the sound file in the app's bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Could not find file: \(filename) in the main bundle.")
            return
        }
        
        do {
            // Initialize the audio player
            player = try AVAudioPlayer(contentsOf: url)
            
            // Set the audio session category to playback
            // This ensures the audio plays even if the device is on silent mode
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Play the sound
            player?.play()
            
            print("Playing audio for story ID: \(storyId)")
        } catch let error {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    // Function to stop the currently playing audio
    func stopSound() {
        if player?.isPlaying == true {
            player?.stop()
            print("Audio playback stopped.")
        }
    }
}
