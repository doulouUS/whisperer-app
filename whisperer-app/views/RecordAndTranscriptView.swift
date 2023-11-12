import SwiftUI
import AVFoundation


struct ContentView: View {
    @Binding var transcriptRecord: TranscriptRecord
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    @State private var recordedFileURL: URL?
    @State private var audioPlayer: AVAudioPlayer?
    
    @State private var status = TranscriptionState.waiting
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(transcriptRecord.theme.mainColor)
            VStack {
                //
                Text(verbatim: "Transcription App")
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits([.isHeader])
                ProgressView(value: 5, total: 100)
                Text(verbatim: "Loading...")
                    .font(.caption)
                    .fontWeight(.light)
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
                Spacer()
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
                Image(systemName: isRecording ? "mic" : "mic.slash")
                    .font(.title)
                    .accessibilityLabel(isRecording ? "recording" : "not recording")
                    .padding(.bottom, 200)
                Circle()
                    .padding(.top, -150)
                    .frame(width: 200.0)
                    .overlay {
                        VStack {
                            if isRecording {
                                Text("Tap to stop recording")
                                    .foregroundColor(Color.red)
                                    .padding(.top, -80)
                            } else {
                                Text("Tap to start recording")
                                    .foregroundColor(Color.white)
                                    .padding(.top, -80)
                            }
                            
                        }
                        .padding()
                    }
                    .onTapGesture {
                        
                        if isRecording {
                            Task {
                                await speechRecognizer.stopTranscribing()
                                populate_ui()
                                
                                print("end transcription")
                            }
                        } else {
                            print("start transcription")
                            startTranscription()
                        }
                    }
                    .onChange(of: isRecording) { newValue in
                        // Toggle state after the function call
                        isRecording = newValue
                    }
            }
        }
        .padding()
        .foregroundColor(transcriptRecord.theme.accentColor)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func startTranscription() {
        // reset Speech Recognizer
        isRecording = true
        status = .running
        // speechRecognizer.resetTranscript()
        // speechRecognizer.startTranscribing()
    }
    
    private func populate_ui() {
        isRecording = false
        do {
            guard let recordedFileURL = speechRecognizer.fileURL else {
                print("Error retrieving file URL")
                return
            }
            audioPlayer = try AVAudioPlayer(contentsOf: recordedFileURL)
            audioPlayer?.prepareToPlay()
            
            // save URL and transcription

            transcriptRecord.soundRecording = recordedFileURL
            if let whisper_transcript = speechRecognizer.whisper_transcript {
                transcriptRecord.transcription = whisper_transcript
            }
        }
        catch {
            print("Error creating AVAudioPlayer: \(error)")
        }
    }
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            transcriptRecord: .constant(TranscriptRecord.sampleData[0])
        )
    }
}
