//
//  AudioPlayer.swift
//  whisperer-app
//
//  Created by Louis DOUGE on 19/11/23.
//

import Foundation
import AVFoundation

enum AudioPlayerError: Error {
    // "No player initialized or audio is not playing so it cannot be paused")
    case alreadyPlaying
}


class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false

    var audioPlayer: AVAudioPlayer?

    func playAudio(url: URL) throws {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error creating AVAudioPlayer: \(error)")
        }
    }

    func pauseAudio() throws {
           if let player = audioPlayer, player.isPlaying {
               player.pause()
               isPlaying = false
           } else {
               throw AudioPlayerError.alreadyPlaying
           }
       }

    func stopAudio() {
        if let player = audioPlayer {
           player.stop()
           player.currentTime = 0
           isPlaying = false
        }
    }
    
    func fastForward(seconds: TimeInterval) {
        if let player = audioPlayer {
            let newTime = min(player.currentTime + seconds, player.duration)
            player.currentTime = newTime
        }
    }

    func fastBackward(seconds: TimeInterval) {
        if let player = audioPlayer {
            let newTime = max(player.currentTime - seconds, 0)
            player.currentTime = newTime
        }
    }

    
    func getAudioDuration(from audioFileURL: URL) -> TimeInterval? {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            let duration = audioPlayer?.duration
            audioPlayer = nil
            return duration
        } catch {
            print("Error creating AVAudioPlayer: \(error)")
            return nil
        }
    }

    // AVAudioPlayerDelegate method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // This method is called when the audio finishes playing
        if flag {
            print("Audio finished playing successfully")
        } else {
            print("Audio finished playing with an error")
        }
        isPlaying = false
        audioPlayer = nil
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        do {
            try self.pauseAudio()
        } catch {
            print("Error pausing audio when interruption starts: \(error)")
        }
    }

}
