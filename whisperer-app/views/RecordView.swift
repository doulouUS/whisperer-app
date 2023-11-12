//
//  RecordView.swift
//  Playground
//
//  Created by Louis DOUGE on 21/4/23.
//

import SwiftUI


struct RecordView: View {
    let record: TranscriptRecord
    var body: some View {
        VStack (alignment: .leading) {
            Text(record.title)
                .font(.headline)
            Spacer()
            HStack {
                Label("\(record.lengthInSeconds)s", systemImage: "clock")
            }
        }
        .padding()
        .foregroundColor(record.theme.accentColor)
    }
}


struct RecordView_Previews: PreviewProvider {
    static var record = TranscriptRecord.sampleData[0]
    static var previews: some View {
        RecordView(record: record)
            .background(record.theme.mainColor)
            .previewLayout(.fixed(width: 400, height: 60))
    }
}
