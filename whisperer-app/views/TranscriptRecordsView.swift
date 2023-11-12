//
//  TranscriptRecordsView.swift
//  Playground
//
//  Created by Louis DOUGE on 21/4/23.
//

import SwiftUI


struct TranscriptRecordsView: View {
    @Binding var transcriptRecords: [TranscriptRecord]
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var newTranscriptRecord = TranscriptRecord.emptyTranscriptRecord
    @State private var isShowingRecordAndTranscriptView = false
    
    let saveAction: ()->Void
    
    var body: some View {
        NavigationView {
            List($transcriptRecords) { $trRecord in
                NavigationLink(destination: RecordDetailsView(record: $trRecord)) {
                    RecordView(record: trRecord)
                }
                .listRowBackground(trRecord.theme.mainColor)
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
                    RecordAndTranscriptRefactored(transcriptRecord: $newTranscriptRecord)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isShowingRecordAndTranscriptView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                isShowingRecordAndTranscriptView = false
                                transcriptRecords.append(newTranscriptRecord)
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
            saveAction: {}
        )
    }
}
