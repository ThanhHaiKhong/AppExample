//
//  AVAudio+FloatData.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 15/4/25.
//

import Accelerate
import AVFoundation

extension AVAudioPCMBuffer {
    /// Returns audio data as an `Array` of `Float` Arrays.
    ///
    /// If stereo:
    /// - `floatChannelData?[0]` will contain an Array of left channel samples as `Float`
    /// - `floatChannelData?[1]` will contains an Array of right channel samples as `Float`
    public func toFloatChannelData() -> [[Float]]? {
        // Do we have PCM channel data?
        guard let pcmFloatChannelData = floatChannelData else {
            return nil
        }

        let channelCount = Int(format.channelCount)
        let frameLength = Int(self.frameLength)
        let stride = self.stride

        // Preallocate our Array so we're not constantly thrashing while resizing as we append.
        let zeroes: [Float] = Array(repeating: 0, count: frameLength)
        var result = Array(repeating: zeroes, count: channelCount)

        // Loop across our channels...
        for channel in 0 ..< channelCount {
            // Make sure we go through all of the frames...
            for sampleIndex in 0 ..< frameLength {
                result[channel][sampleIndex] = pcmFloatChannelData[channel][sampleIndex * stride]
            }
        }

        return result
    }
}

extension AVAudioFile {
    /// converts to a 32 bit PCM buffer
    public func toAVAudioPCMBuffer() -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: AVAudioFrameCount(length)) else {
            return nil
        }

        do {
            framePosition = 0
            try read(into: buffer)
            print("Created buffer with format")
        } catch let error as NSError {
            print("Cannot read into buffer " + error.localizedDescription)
        }

        return buffer
    }

    public func floatChannelData() -> [[Float]]? {
        guard let pcmBuffer = toAVAudioPCMBuffer(),
              let data = pcmBuffer.toFloatChannelData()
        else {
            return nil
        }
        
        return data
    }
}
