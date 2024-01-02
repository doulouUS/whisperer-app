//
//  RecordAndTranscriptRefactored.swift
//  whisperer-app
//
//  Created by Louis DOUGE on 28/10/23.
//

import SwiftUI
import AVFoundation

import SwiftWhisper


enum TranscriptionState: Equatable {
    case waiting, recording, running, finished
}


struct RecordAndTranscriptRefactored: View {
    @Binding var transcriptRecord: TranscriptRecord
    @State private var status = TranscriptionState.waiting
    
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    @StateObject var transcriptionManager: TranscriptionManager

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(transcriptRecord.theme.mainColor)
            VStack {
                Text(verbatim: "Transcription App")
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits([.isHeader])
                TextField("Title", text: $transcriptRecord.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                ScrollView {
                    Text(verbatim: transcriptRecord.transcription)
                        .font(.body)
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                }
                switch status {
                case .waiting:
                    Image(systemName: "mic.slash")
                        .font(.title)
                        .accessibilityLabel("not recording")
                        .padding(.bottom, 200)
                    Circle()
                        .padding(.top, -150)
                        .frame(width: 200.0)
                        .overlay {
                            VStack {
                                Text("Tap to start recording")
                                    .foregroundColor(Color.white)
                                    .padding(.top, -80)
                            }
                            .padding()
                        }
                        .onTapGesture {
                            withAnimation(nil) {
                                print("Start recording")
                                status = .recording
                                audioRecorderManager.startRecording()
                            }
                        }
                        /*
                        .onAppear {
                            do {
                                try transcriptionManager.load_whisper()
                            } catch {
                                print("Failed loading model")
                            }
                        }
                         */
                    
                case .recording:
                    Image(systemName: "mic")
                        .font(.title)
                        .accessibilityLabel("recording")
                        .padding(.bottom, 200)
                    Circle()
                        .padding(.top, -150)
                        .frame(width: 200.0)
                        .overlay {
                            VStack {
                                Text("Tap to stop recording")
                                        .foregroundColor(Color.red)
                                        .padding(.top, -80)
                            }
                            .padding()
                        }
                        .onTapGesture {
                            withAnimation(nil) {
                                print("Stop recording")
                                status = .running
                                audioRecorderManager.stopRecording()
                            }
                        }
                    
                case .running:
                    ProgressView(value: transcriptionManager.progress, total: 1.0)
                    Text(verbatim: "Loading...")
                        .font(.caption)
                        .fontWeight(.light)
                    Image(systemName: "mic.slash")
                        .font(.title)
                        .accessibilityLabel("not recording")
                        .padding(.bottom, 200)
                    Circle()
                        .padding(.top, -150)
                        .frame(width: 200.0)
                        .overlay {
                            VStack {
                                Text("Transcribing...")
                                        .foregroundColor(Color.white)
                                        .padding(.top, -80)
                            }
                            .padding()
                        }
                        .onAppear {
                            withAnimation(nil) {
                                if let file_url = audioRecorderManager.fileURL {
                                    print("Start transcription")
                                    do {
                                        let _ = try transcriptionManager.transcribe(file: file_url, transcriptRecord: $transcriptRecord, status: $status)
                                    }
                                    catch {
                                        print("Failed transcription")
                                        
                                    }
                                }
                            }
                        }
                        .onDisappear {
                            transcriptionManager.progress = 0.0
                        }
                        
                    
                case .finished:
                    HStack {
                        if let soundRecordingURL = transcriptRecord.soundRecording {
                                Button(action: {
                                    do {
                                        try audioPlayerManager.playAudio(url: soundRecordingURL)
                                    } catch {
                                        print("Error playing audio: \(error)")
                                    }
                                }) {
                                    Image(systemName: "play.circle")
                                        .font(.system(size: 50))
                                }
                                 .disabled(audioPlayerManager.isPlaying)
                                
                                Button(action: {
                                    audioPlayerManager.stopAudio()
                                }) {
                                    Image(systemName: "stop.circle")
                                        .font(.system(size: 50))
                                }
                                .disabled(!audioPlayerManager.isPlaying)
                        } else
                        {
                            EmptyView()
                        }
                    }
                    .padding(.top, 20)
                    Image(systemName: "mic.slash")
                        .font(.title)
                        .accessibilityLabel("not recording")
                        .padding(.bottom, 200)
                
                    Circle()
                        .padding(.top, -150)
                        .frame(width: 200.0)
                        .overlay {
                            VStack {
                                Text("Tap to start recording")
                                        .foregroundColor(Color.white)
                                        .padding(.top, -80)
                            }
                            .padding()
                        }
                        .onTapGesture {
                            print("Start recording")
                            status = .recording
                            audioRecorderManager.startRecording()
                        }
                        .onAppear {
                            if let soundRecordingURL = transcriptRecord.soundRecording {
                                if let audioDuration = audioPlayerManager.getAudioDuration(from: soundRecordingURL) {
                                    transcriptRecord.lengthInSeconds = Int(audioDuration)
                                }
                                }
                        }
                }
                
            }
        }
        .padding()
        .foregroundColor(transcriptRecord.theme.accentColor)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func transcribe(file audioFileURL: URL, transcriptRecord: Binding<TranscriptRecord>) throws {
        guard let modelURL = Bundle.main.url(
            forResource: "ggml-tiny.en",
            withExtension: "bin",
            subdirectory: "openai_models"
        ) else { throw ModelLoadingError.modelnotfound }

        let whisper = Whisper(fromFileURL: modelURL)
        var whisper_transcript: String = ""

        convertAudioFileToPCMArray(fileURL: audioFileURL) { result in
            guard case .success(let frames) = result else { return }

            whisper.transcribe(audioFrames: frames) { result in
                guard case .success(let segments) = result else { return }
                
                whisper_transcript = segments.map(\.text).joined()
                print("transcription: \(whisper_transcript)")
                
                // Dispatch UI related code to main queue so the UI can update itself
                DispatchQueue.main.async {
                    transcriptRecord.wrappedValue.transcription = whisper_transcript
                    transcriptRecord.wrappedValue.soundRecording = audioFileURL
                }
            }
        }
    }
}

/*
struct RecordAndTranscriptRefactored_Previews: PreviewProvider {
    static var previews: some View {
        RecordAndTranscriptRefactored(
            transcriptRecord: .constant(TranscriptRecord.sampleData[0]),
            transcriptionManager:
        )
    }
}
*/
