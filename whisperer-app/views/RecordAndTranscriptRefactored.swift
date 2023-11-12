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

enum ModelLoadingError: Error {
    case modelnotfound
}


struct RecordAndTranscriptRefactored: View {
    @Binding var transcriptRecord: TranscriptRecord
    @State private var status = TranscriptionState.waiting
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @State private var audioPlayer: AVAudioPlayer?

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
                                speechRecognizer.startRecording()
                            }
                        }
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
                                speechRecognizer.stopRecording()
                                status = .running
                            }
                        }
                    
                case .running:
                    ProgressView(value: 5, total: 100)
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
                            if let file_url = speechRecognizer.fileURL {
                                print("Start transcription")
                                do {
                                    let _ = try transcribe(file: file_url)
                                    
                                }
                                catch {
                                    print("Failed transcription")
                                    
                                }
                            }
                        }
                        
                    
                case .finished:
                    HStack {
                        if let _ = transcriptRecord.soundRecording {
                                Button(action: {
                                    audioPlayer?.play()
                                }) {
                                    Image(systemName: "play.circle")
                                        .font(.system(size: 50))
                                }
                                .disabled(transcriptRecord.soundRecording == nil)
                                
                                Button(action: {
                                    audioPlayer?.stop()
                                    audioPlayer?.currentTime = 0
                                }) {
                                    Image(systemName: "stop.circle")
                                        .font(.system(size: 50))
                                }
                                .disabled(transcriptRecord.soundRecording == nil)
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
                            speechRecognizer.startRecording()
                        }
                    /*
                        .onChange(of: isRecording) { newValue in
                            // Toggle state after the function call
                            isRecording = newValue
                        }
                     */
                }
                
            }
        }
        .padding()
        .foregroundColor(transcriptRecord.theme.accentColor)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func transcribe(file audioFileURL: URL) throws {
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
                
                transcriptRecord.transcription = whisper_transcript
                transcriptRecord.soundRecording = audioFileURL
                
                status = .finished
            }
        }
    }
}


struct RecordAndTranscriptRefactored_Previews: PreviewProvider {
    static var previews: some View {
        RecordAndTranscriptRefactored(
            transcriptRecord: .constant(TranscriptRecord.sampleData[0])
        )
    }
}
