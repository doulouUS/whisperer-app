//
//  File.swift
//  Playground
//
//  Created by Louis DOUGE on 7/5/23.
//

import SwiftUI

    

struct RecordAndTranscriptHeaderView: View {
    let secondsElapsed: Int
    let totalTranscriptionTime: Int
    private var percentageTimeElapsed: Double {
        guard totalTranscriptionTime > 0 else {return 1}
        return Double(secondsElapsed) / Double(totalTranscriptionTime) * 100
    }
    var body: some View {
        VStack {
            Text(verbatim: "Transcription App")
                .font(.title)
                .fontWeight(.bold)
            ProgressView(value: percentageTimeElapsed, total: 100)
            Text(verbatim: "Loading...")
                .font(.caption)
                .fontWeight(.light)
        }
        .accessibilityAddTraits([.isHeader])
    }
}

    

struct MeetingHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        RecordAndTranscriptHeaderView(secondsElapsed: 60, totalTranscriptionTime: 100)
            .previewLayout(.sizeThatFits)
    }
}
