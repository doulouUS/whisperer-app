//
//  Transcriber.swift
//  whisperer-app
//
//  Created by Louis DOUGE on 19/11/23.
//

import Foundation
import SwiftWhisper
import SwiftUI


enum ModelLoadingError: Error {
    case modelnotfound
}

class TranscriptionManager: NSObject, ObservableObject {
    private var whisper: Whisper?
    @Published var isModelLoaded = false
    @Published var progress: Double = 0.0
    
    func load_whisper() throws {
        guard let modelURL = Bundle.main.url(
            forResource: "ggml-tiny.en",
            withExtension: "bin",
            subdirectory: "openai_models"
        ) else { throw ModelLoadingError.modelnotfound }

        whisper = Whisper(fromFileURL: modelURL)
        whisper?.delegate = self
        print("Model loaded")
        DispatchQueue.main.async {
            self.isModelLoaded = true
        }
    }
    
    func transcribe(file audioFileURL: URL, transcriptRecord: Binding<TranscriptRecord>, status: Binding<TranscriptionState>) throws {
        
        var whisper_transcript: String = ""

        convertAudioFileToPCMArray(fileURL: audioFileURL) { result in
            guard case .success(let frames) = result else { return }

            self.whisper?.transcribe(audioFrames: frames) { result in
                guard case .success(let segments) = result else { return }
                
                whisper_transcript = segments.map(\.text).joined()
                print("transcription: \(whisper_transcript)")
                
                // Dispatch UI related code to main queue so the UI can update itself
                DispatchQueue.main.async {
                    transcriptRecord.wrappedValue.transcription = whisper_transcript
                    transcriptRecord.wrappedValue.soundRecording = audioFileURL
                    status.wrappedValue = .finished
                }
            }
        }
    }
}

extension TranscriptionManager: WhisperDelegate {
    func whisper(_ aWhisper: Whisper, didUpdateProgress progress: Double) {
        // Update progress
        self.progress = progress
    }

    func whisper(_ aWhisper: Whisper, didProcessNewSegments segments: [Segment], atIndex index: Int) {
        // Handle new transcribed segments if needed
    }

    func whisper(_ aWhisper: Whisper, didCompleteWithSegments segments: [Segment]) {
        // Transcription completed
    }

    func whisper(_ aWhisper: Whisper, didErrorWith error: Error) {
        // Handle transcription error
    }
}
