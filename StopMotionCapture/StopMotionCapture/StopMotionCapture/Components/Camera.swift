//
//  Camera.swift
//  StopMotionCapture
//
//  Created by Fumito Kimura on 2025/06/16.
//

import SwiftUI
import AVFoundation

private func getFileCount(dir: String) -> Int {
    let fileManager = FileManager.default
    do {
        let contents = try fileManager.contentsOfDirectory(at: URL(string: dir)!, includingPropertiesForKeys: nil)
        return contents.count
    } catch {
        return 0
    }
}

private func NSImageToPNG(image: NSImage) -> Data? {
    guard let cgImage: CGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
    let rep: NSBitmapImageRep = NSBitmapImageRep(cgImage: cgImage)
    return rep.representation(using: .png, properties: [:])
}

class Camera: NSObject {
    let captureSession: AVCaptureSession = AVCaptureSession()
    var handler: ((CMSampleBuffer) -> Void)?

    override init() {
        super.init()
        setup()
    }

    func setup() {
        captureSession.beginConfiguration()
        let captureDevice: AVCaptureDevice = AVCaptureDevice.default(.external, for: .video, position: .back) ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
        guard let captureDeviceInput: AVCaptureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
              captureSession.canAddInput(captureDeviceInput)
        else { return }
        captureSession.addInput(captureDeviceInput)

        let captureVideoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        captureVideoDataOutput.setSampleBufferDelegate(self, queue: .main)
        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        guard captureSession.canAddOutput(captureVideoDataOutput) else { return }
        captureSession.addOutput(captureVideoDataOutput)

        captureSession.commitConfiguration()
    }

    func boot(_ handler: @escaping (CMSampleBuffer) -> Void)  {
        if !captureSession.isRunning {
            self.handler = handler
            captureSession.startRunning()
        }
    }

    func takePhoto(framesDir: String, frame: NSImage) {
        let framesNum: Int = getFileCount(dir: framesDir)
        let imageURL: URL = URL(string: framesDir + "frame_" + String(framesNum) + ".png")!
        if let data: Data = NSImageToPNG(image: frame) {
            do {
                try data.write(to: imageURL)
            } catch {
                return
            }
        }
    }

    func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
 }

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let handler = handler {
            handler(sampleBuffer)
        }
    }
}
