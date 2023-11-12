//
//  Records.swift
//  Playground
//
//  Created by Louis DOUGE on 21/4/23.
//

import Foundation

struct TranscriptRecord: Identifiable, Codable {
    var id: UUID
    var title: String
    var lengthInSeconds: Int
    var soundRecording: URL?
    var transcription: String
    var theme: Theme
    
    init(id: UUID = UUID(), title: String, lengthInSeconds: Int, soundRecording: URL?, transcription: String, theme: Theme) {

        self.id = id
        self.title = title
        self.lengthInSeconds = lengthInSeconds
        self.soundRecording = soundRecording
        self.transcription = transcription
        self.theme = theme
    }
}

extension TranscriptRecord {
    static var emptyTranscriptRecord: TranscriptRecord {
        TranscriptRecord(title: "", lengthInSeconds: 0, soundRecording: nil, transcription: "", theme: .sky)
    }
}

extension TranscriptRecord {
    static let sampleData: [TranscriptRecord] = [
        TranscriptRecord(title: "Text to my friend",
                   lengthInSeconds: 12,
                         soundRecording: nil,  //URL(string: "sound_file_1"),
                   transcription: "Hi, just to let you know I'll be visiting next week-end, let me know if I can bring anything. See you!",
                   theme: .yellow),
        TranscriptRecord(title: "Reminder for dance group",
                   lengthInSeconds: 8,
                    soundRecording: nil,  // URL(string: "sound_file_2"),
                   transcription: "Guys! Well done on the competition yesterday!",
                   theme: .orange)
    ]
}
