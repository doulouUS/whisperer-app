import Foundation
import AVFoundation
import AudioKit

import SwiftUI
import Speech
import SwiftWhisper

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
/// TODO
///  - make sure onTap leads to start of recording, no delay
///  - load whisper model earlier to avoid downtime (may need to transcribe fake audio as first run is slower)
///  - fix shift in whisper_transcript
///  - optimization with prod setup (see github repo)
///  - update interface with length of sound
///  - give one unique name to recordings
///  - check why adding a new recording seems to keep content to all previously recorded transcriptions

class AudioRecorderManager: ObservableObject {
    enum RecognizerError: Error {
        // case nilRecognizer
        // case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable

        var message: String {
            switch self {
            // case .nilRecognizer: return "Can't initialize speech recognizer"
            // case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }

    @MainActor var transcript: String = ""

    private var audioEngine: AVAudioEngine?
    public var fileURL: URL?
    public var whisper_transcript: String? = ""
    

    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     **/

    init() {
        
        Task {
            do {
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                transcribe(error)
            }
        }
    }
    
    @MainActor func startRecording() {
        Task {
            await record()
        }
    }

    @MainActor func stopRecording() {
        Task {
            await reset()
        }
    }

    func stopTranscribing() async {
        await reset()
        await run_speech_to_text()
    }

    /**
     Begin transcribing audio.
     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
     The resulting transcription is continuously written to the published `transcript` property.

     */

    private func record() async {
        do {
            let (audioEngine, fileURL) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.fileURL = fileURL
            
        } catch {
            await self.reset()
            self.transcribe(error)
        }
    }

    /// Reset the speech recognizer.
    private func reset() async {
        audioEngine?.stop()
        audioEngine = nil
    }
    
    private func run_speech_to_text() async {
        
        if let modelURL = Bundle.main.url(
            forResource: "ggml-tiny.en",
            withExtension: "bin",
            subdirectory: "openai_models"
        ) {
            if let url_to_file = self.fileURL {
                let whisper = Whisper(fromFileURL: modelURL)
                
                await MainActor.run {
                    convertAudioFileToPCMArray(fileURL: url_to_file, whisper: whisper) { result in
                        guard case .success(let frames) = result else { return }
                        
                        whisper.transcribe(audioFrames: frames) { result in
                            guard case .success(let segments) = result else { return }
                            
                            let w_t = segments.map(\.text).joined()
                            print("Transcription result:\(w_t)")
                            self.whisper_transcript = w_t
                        }
                    }
                }
            }
            else {
                print("No file URL behind audio.")
            }
        }
        else {
            print("Whisper model file not found.")
        }
    }
    
    func getFileURL() -> URL? {
        return self.fileURL
    }

    private static func prepareEngine() throws -> (AVAudioEngine, URL) {
        let audioEngine = AVAudioEngine()

        // File destination
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // Session related preparation
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.inputFormat(forBus: 0)

        // AVAudioFile uses the Core Audio Format (CAF) to write to disk.
        // Specify the file URL with a .caf extension.
        let filename = generateFileName()
        let fileURL = documentURL.appendingPathComponent("\(filename).caf")
        print(fileURL.absoluteString)

        let file = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            do {
                try file.write(from: buffer)
            } catch {
                print("Error writing audio buffer to file: \(error)")
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, fileURL)
    }

    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }

    nonisolated private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }

        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
        }
    }
}

func generateFileName() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss-dd-MM-yyyy"
    let formattedDate = dateFormatter.string(from: Date())
    
    let fileName = "recording-\(formattedDate)"
    return fileName
}

func convertAudioFileToPCMArray(fileURL: URL, whisper: Whisper, completionHandler: @escaping (Result<[Float], Error>) -> Void) {
    var options = FormatConverter.Options()
    options.format = .wav
    options.sampleRate = 16000
    options.bitDepth = 16
    options.channels = 1
    options.isInterleaved = false

    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    let converter = FormatConverter(inputURL: fileURL, outputURL: tempURL, options: options)
    converter.start { error in
        if let error {
            completionHandler(.failure(error))
            return
        }

        let data = try! Data(contentsOf: tempURL) // Handle error here

        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }

        try? FileManager.default.removeItem(at: tempURL)

        completionHandler(.success(floats))
    }
}


//extension SFSpeechRecognizer {
//    static func hasAuthorizationToRecognize() async -> Bool {
//        await withCheckedContinuation { continuation in
//            requestAuthorization { status in
//                continuation.resume(returning: status == .authorized)
//            }
//        }
//    }
//}


extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}


