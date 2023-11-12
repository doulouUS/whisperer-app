//
//  Store.swift
//  Playground
//
//  Created by Louis DOUGE on 19/5/23.
//

import Foundation
import SwiftUI


@MainActor
class Store: ObservableObject {
    @Published var transcriptRecords: [TranscriptRecord] = []
    
    // function to have access to docs simplified
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("transcripts.data")
        
    }
    
    func load() async throws {
        let task = Task<[TranscriptRecord], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                    return []
                }
            let transcriptsRecords = try JSONDecoder().decode([TranscriptRecord].self, from: data)
            return transcriptsRecords
        }
        
        let transcripts = try await task.value
        self.transcriptRecords = transcripts
    }
    
    func save(record: [TranscriptRecord]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(record)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
