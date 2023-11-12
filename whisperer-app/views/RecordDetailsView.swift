//
//  RecordDetailsView.swift
//  Playground
//
//  Created by Louis DOUGE on 21/4/23.
//

import SwiftUI
import AVFoundation

struct RecordDetailsView: View {
    @Binding var record: TranscriptRecord
    
    @State private var audioPlayer: AVAudioPlayer?
    
    @State private var isPresentingEditView = false
    
    var body: some View {
        VStack {
            Text(verbatim: record.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .accessibilityAddTraits([.isHeader])
            
            HStack {
                Label("\(record.lengthInSeconds)s", systemImage: "clock")
            }
            
            Spacer()
                .frame(height: 40.0)
            
            Text(verbatim: record.transcription)
                .font(.body)
                .fontWeight(.light)
                .multilineTextAlignment(.leading)
            
            HStack {
                if let soundRecordingURL = record.soundRecording {
                    Button(action: {
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: soundRecordingURL)
                            audioPlayer?.prepareToPlay()
                            audioPlayer?.play()
                        } catch {
                            print("Error creating AVAudioPlayer: \(error)")
                        }
                    }) {
                        Image(systemName: "play.circle")
                            .font(.system(size: 50))
                    }
                    .disabled(audioPlayer != nil)
                    
                    Button(action: {
                        audioPlayer?.stop()
                        audioPlayer?.currentTime = 0
                        audioPlayer = nil
                    }) {
                        Image(systemName: "stop.circle")
                            .font(.system(size: 50))
                    }
                    .disabled(audioPlayer == nil)
                } else {
                    EmptyView()
                }
            }
        }
        .padding()
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                RecordDetailsEditView(transcriptRecord: $record)
                    .navigationTitle("Edit transcript title")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                            }
                        }
                    }
            }
        }
    }
}

struct RecordDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            RecordDetailsView(record: .constant(TranscriptRecord.sampleData[0]))
        }
    }
}
