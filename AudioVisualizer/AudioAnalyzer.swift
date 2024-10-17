import AVFoundation

class AudioAnalyzer {
    func analyzeAudio(url: URL) -> [Float] {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let format = audioFile.processingFormat
            let frameCount = UInt32(audioFile.length)
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
            try audioFile.read(into: buffer)
            
            guard let channelData = buffer.floatChannelData?[0] else { return [] }
            
            let sampleCount = Int(buffer.frameLength)
            return Array(UnsafeBufferPointer(start: channelData, count: sampleCount))
        } catch {
            print("Error analyzing audio: \(error)")
            return []
        }
    }
}
