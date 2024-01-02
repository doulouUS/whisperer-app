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
    
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
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
            
            
            if let soundRecordingURL = record.soundRecording {
                Spacer()
                AudioPlayerView(audioPlayerManager: audioPlayerManager, soundRecordingURL: soundRecordingURL)
            } else {
                EmptyView()
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
