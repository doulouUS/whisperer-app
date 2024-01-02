//
//  RecordDetailsEditView.swift
//  Playground
//
//  Created by Louis DOUGE on 23/4/23.
//

import SwiftUI


struct RecordDetailsEditView: View {
    @Binding var transcriptRecord: TranscriptRecord
    var body: some View {
        Form {
            Section(header: TextField("Title", text: $transcriptRecord.title)) {
            }
            Section(header: TextField("Transcribed content", text: $transcriptRecord.transcription)) {
            }
        }
    }

}


struct RecordDetailsEditView_Previews: PreviewProvider {

    static var previews: some View {
        RecordDetailsEditView(
            transcriptRecord: .constant(TranscriptRecord.emptyTranscriptRecord)
        )
    }
}
