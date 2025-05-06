//
//  Renderer.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 15/4/25.
//

import Foundation
import Metal
import MetalKit
import SwiftUI

let MaxBuffers = 3

public class Renderer: NSObject {
    public var device: MTLDevice!
    public var queue: MTLCommandQueue!
    public var pipeline: MTLRenderPipelineState!
    public var source = ""
    public var constants = Constants()

    private let inflightSemaphore = DispatchSemaphore(value: MaxBuffers)

    public var minBuffers: [MTLBuffer] = []
    public var maxBuffers: [MTLBuffer] = []

    public var samples = SampleBuffer(samples: [0])
    public var start = 0
    public var length = 0

    public let layerRenderPassDescriptor: MTLRenderPassDescriptor

    public init(device: MTLDevice) {
        self.device = device
        queue = device.makeCommandQueue()

        let library = try! device.makeDefaultLibrary(bundle: Bundle.module)

        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = library.makeFunction(name: "waveform_vert")
        rpd.fragmentFunction = library.makeFunction(name: "waveform_frag")

        let colorAttachment = rpd.colorAttachments[0]!
        colorAttachment.pixelFormat = .bgra8Unorm
        colorAttachment.isBlendingEnabled = true
        colorAttachment.sourceRGBBlendFactor = .sourceAlpha
        colorAttachment.sourceAlphaBlendFactor = .sourceAlpha
        colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        pipeline = try! device.makeRenderPipelineState(descriptor: rpd)

        minBuffers = [device.makeBuffer([0])!]
        maxBuffers = [device.makeBuffer([0])!]

        layerRenderPassDescriptor = MTLRenderPassDescriptor()
        layerRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        layerRenderPassDescriptor.colorAttachments[0].storeAction = .store
        layerRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);

        super.init()
    }

    public func selectBuffers(width: CGFloat) -> (MTLBuffer?, MTLBuffer?) {
        var level = 0
        for (minBuffer, maxBuffer) in zip(minBuffers, maxBuffers) {
            if CGFloat(minBuffer.length / MemoryLayout<Float>.size) < width {
                return (minBuffer, maxBuffer)
            }
            level += 1
        }

        // Use optional binding to safely access last element of each array
        if let minBufferLast = minBuffers.last, let maxBufferLast = maxBuffers.last {
            return (minBufferLast, maxBufferLast)
        } else {
            // If either array is empty, return nil
            return (nil, nil)
        }
    }
    
    public func encode(to commandBuffer: MTLCommandBuffer, pass: MTLRenderPassDescriptor, width: CGFloat) {
        pass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)

        let highestResolutionCount = Float(samples.samples.count)
        let startFactor = Float(start) / highestResolutionCount
        let lengthFactor = Float(length) / highestResolutionCount

        let (minBufferOpt, maxBufferOpt) = selectBuffers(width: width / CGFloat(lengthFactor))
        guard let minBuffer = minBufferOpt, let maxBuffer = maxBufferOpt else {
            //early return to gracefully fail.
            return
        }

        let enc = commandBuffer.makeRenderCommandEncoder(descriptor: pass)!
        enc.setRenderPipelineState(pipeline)

        let bufferLength = Float(minBuffer.length / MemoryLayout<Float>.size)
        let bufferStart = Int(bufferLength * startFactor)
        var bufferCount = Int(bufferLength * lengthFactor)

        enc.setFragmentBuffer(minBuffer, offset: bufferStart * MemoryLayout<Float>.size, index: 0)
        enc.setFragmentBuffer(maxBuffer, offset: bufferStart * MemoryLayout<Float>.size, index: 1)
        assert(minBuffer.length == maxBuffer.length)
        enc.setFragmentBytes(&bufferCount, length: MemoryLayout<Int32>.size, index: 2)
        let c = [constants]
        enc.setFragmentBytes(c, length: MemoryLayout<Constants>.size, index: 3)
        enc.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        enc.endEncoding()
    }

    public func draw(to layer: CAMetalLayer) {
        let size = layer.drawableSize
        let w = Float(size.width)
        let h = Float(size.height)
        
        if w == 0 || h == 0 {
            return
        }

        _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)

        let commandBuffer = queue.makeCommandBuffer()!

        let semaphore = inflightSemaphore
        commandBuffer.addCompletedHandler { _ in
            semaphore.signal()
        }

        if let currentDrawable = layer.nextDrawable() {
            layerRenderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
            encode(to: commandBuffer, pass: layerRenderPassDescriptor, width: size.width)
            commandBuffer.present(currentDrawable)
        } else {
            print("⚠️ couldn't get drawable")
        }
        
        commandBuffer.commit()
    }

    public func set(samples: SampleBuffer, start: Int, length: Int) async {
        self.start = start
        self.length = length
        if samples === self.samples {
            return
        }
        self.samples = samples

        let buffers = makeBuffers(device: device, samples: samples)
        self.minBuffers = buffers.0
        self.maxBuffers = buffers.1
    }
}

#if !os(visionOS)
extension Renderer: MTKViewDelegate {

    public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {
        
    }

    public func draw(in view: MTKView) {
        let size = view.frame.size
        let w = Float(size.width)
        let h = Float(size.height)
        
        if w == 0 || h == 0 {
            return
        }

        _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)

        let commandBuffer = queue.makeCommandBuffer()!

        let semaphore = inflightSemaphore
        commandBuffer.addCompletedHandler { _ in
            semaphore.signal()
        }

        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
            encode(to: commandBuffer, pass: renderPassDescriptor, width: size.width)
            commandBuffer.present(currentDrawable)
        }
        
        commandBuffer.commit()
    }
}
#endif

public func makeBuffers(device: MTLDevice, samples: SampleBuffer) -> ([MTLBuffer], [MTLBuffer]) {
    var minSamples = samples.samples
    var maxSamples = samples.samples

    var s = samples.samples.count
    var minBuffers: [MTLBuffer] = []
    var maxBuffers: [MTLBuffer] = []
    
    while s > 2 {
        minBuffers.append(device.makeBuffer(minSamples)!)
        maxBuffers.append(device.makeBuffer(maxSamples)!)

        minSamples = binMin(samples: minSamples, binSize: 2)
        maxSamples = binMax(samples: maxSamples, binSize: 2)
        s /= 2
    }
    
    return (minBuffers, maxBuffers)
}
