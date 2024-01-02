//
//  AudioPlayerView.swift
//  whisperer-app
//
//  Created by Louis DOUGE on 22/11/23.
//

import SwiftUI

enum AudioPlayerState: Equatable {
    case playing, stopped, finished
}

struct AudioPlayerView: View {
    @StateObject var audioPlayerManager: AudioPlayerManager
    @State private var status = AudioPlayerState.stopped
    
    @State private var timer: Timer?
    
    let soundRecordingURL: URL
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var remainingTime: TimeInterval = 0
    
    var body: some View {
        VStack (spacing: 0) {
            switch status {
            case .playing:
                AudioProgressBarView(elapsedTime: $elapsedTime, remainingTime: $remainingTime)
                HStack {
                    Button(action: {
                        audioPlayerManager.fastBackward(seconds: 0.5)
                    }) {
                        Image(systemName: "backward")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: {
                        do {
                            try audioPlayerManager.pauseAudio()
                            status = .stopped
                        } catch {
                            print("Error playing audio: \(error)")
                        }
                    }) {
                        Image(systemName: "pause")
                            .font(.system(size: 70))
                    }
                    Spacer()
                    Button(action: {
                        audioPlayerManager.fastForward(seconds: 0.5)
                    }) {
                        Image(systemName: "forward")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                    }.onChange(of: audioPlayerManager.isPlaying) { isPlaying in
                        if !isPlaying {
                            elapsedTime = audioPlayerManager.getAudioDuration(from: soundRecordingURL) ?? 0
                            remainingTime = 0
                            status = .finished
                        }
                    }
                    .onAppear{
                        // Update elapsed and remaining time periodically
                        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                            updatePlaybackProgress()
                        }
                    }
                }.padding(60)
                    
            case .stopped:
                AudioProgressBarView(elapsedTime: $elapsedTime, remainingTime: $remainingTime)
                HStack {
                    Button(action: {
                        audioPlayerManager.fastBackward(seconds: 0.5)
                    }) {
                        Image(systemName: "backward")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: {
                        do {
                            try audioPlayerManager.playAudio(url: soundRecordingURL)
                            status = .playing
                        } catch {
                            print("Error playing audio: \(error)")
                        }
                    }) {
                        Image(systemName: "play")
                            .font(.system(size: 70))
                    }
                    Spacer()
                    Button(action: {
                        audioPlayerManager.fastForward(seconds: 0.5)
                    }) {
                        Image(systemName: "forward")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                    }.onChange(of: audioPlayerManager.isPlaying) { isPlaying in
                        if !isPlaying {
                            elapsedTime = audioPlayerManager.getAudioDuration(from: soundRecordingURL) ?? 0
                            remainingTime = 0
                            status = .finished
                        }
                    }
                }.padding(60)
                
            case .finished:
                AudioProgressBarView(elapsedTime: $elapsedTime, remainingTime: $remainingTime)
                HStack {
                    Button(action: {
                        audioPlayerManager.fastBackward(seconds: 0.5)
                    }) {
                        Image(systemName: "backward")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: {
                        do {
                            try audioPlayerManager.playAudio(url: soundRecordingURL)
                            status = .playing
                        } catch {
                            print("Error playing audio: \(error)")
                        }
                    }) {
                        Image(systemName: "play")
                            .font(.system(size: 70))
                    }
                    Spacer()
                    Button(action: {
                        audioPlayerManager.fastForward(seconds: 0.5)
                    }) {
                        Image(systemName: "forward")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                    }
                }.padding(60)
            }
        }
        .onAppear {
            remainingTime = (audioPlayerManager.getAudioDuration(from: soundRecordingURL) ?? 0)
        }
        .onDisappear {
            // Invalidate and clear the timer when the view disappears
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func updatePlaybackProgress() {
        guard let audioPlayer = audioPlayerManager.audioPlayer else { return }

        elapsedTime = audioPlayer.currentTime
        remainingTime = max(audioPlayer.duration - audioPlayer.currentTime, 0)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize the soundURL directly within the previews property
        let soundURL: URL? = Bundle.main.url(forResource: "speech-1", withExtension: "wav", subdirectory: "Preview Assets")
        
        // Use the nil-coalescing operator to provide a default URL if soundURL is nil
        let url = soundURL ?? URL(fileURLWithPath: "defaultURL")
        print(url)
        // Initialize and preview the AudioPlayerView
        return AudioPlayerView(audioPlayerManager: AudioPlayerManager(), soundRecordingURL: url)
    }
}
