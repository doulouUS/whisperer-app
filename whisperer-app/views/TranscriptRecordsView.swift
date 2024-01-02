//
//  TranscriptRecordsView.swift
//  Playground
//
//  Created by Louis DOUGE on 21/4/23.
//

import SwiftUI


struct TranscriptRecordsView: View {
    @Binding var transcriptRecords: [TranscriptRecord]
    @StateObject var transcriptionManager: TranscriptionManager
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var newTranscriptRecord = TranscriptRecord.emptyTranscriptRecord
    @State private var isShowingRecordAndTranscriptView = false
    
    let saveAction: ()->Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach($transcriptRecords) { $trRecord in
                    NavigationLink(destination: RecordDetailsView(record: $trRecord)) {
                        RecordView(record: trRecord)
                    }
                    .listRowBackground(trRecord.theme.mainColor)
                }
                .onDelete { indexSet in
                    transcriptRecords.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Transcripts")
            .toolbar {
                Button(action: {
                    isShowingRecordAndTranscriptView = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New transcript")
            }
            .fullScreenCover(isPresented: $isShowingRecordAndTranscriptView) {
                NavigationView {
                    RecordAndTranscriptRefactored(transcriptRecord: $newTranscriptRecord, transcriptionManager: transcriptionManager)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isShowingRecordAndTranscriptView = false
                                newTranscriptRecord = TranscriptRecord.emptyTranscriptRecord
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                isShowingRecordAndTranscriptView = false
                                transcriptRecords.append(newTranscriptRecord)
                                newTranscriptRecord = TranscriptRecord.emptyTranscriptRecord
                            }
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .inactive { saveAction() }
            }
        }
    }
}


struct TranscriptRecordsView_Previews: PreviewProvider {

    static var previews: some View {
        TranscriptRecordsView(
            transcriptRecords: .constant(TranscriptRecord.sampleData),
            transcriptionManager: TranscriptionManager(),
            saveAction: {}
        )
    }
}

