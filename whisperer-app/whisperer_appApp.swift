import SwiftUI

@main
struct MyApp: App {
    @StateObject private var store = Store()
    @State private var errorWrapper: ErrorWrapper?
    
    @StateObject var transcriptionManager = TranscriptionManager()

    var body: some Scene {
        WindowGroup {
            TranscriptRecordsView(transcriptRecords: $store.transcriptRecords, transcriptionManager: transcriptionManager) {
                Task {
                    do {
                        try await store.save(record: store.transcriptRecords)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .onAppear {
                do {
                    try transcriptionManager.load_whisper()
                } catch {
                    print("Failed loading model")
                }
            }
            .task {
                do {
                    try await store.load()
                } catch {
                    errorWrapper = ErrorWrapper(
                        error: error,
                        guidance: "The transcription app will load sample data and continue.")
                }
            }
            .sheet(item: $errorWrapper) {

                            store.transcriptRecords = TranscriptRecord.sampleData

                        } content: { wrapper in

                            ErrorView(errorWrapper: wrapper)

                        }
        }
    }
}
