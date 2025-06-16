//
//  MenuView.swift
//  StopMotionCapture
//
//  Created by Fumito Kimura on 2025/06/16.
//

import SwiftUI
import AVFoundation

struct MenuView: View {
    
    private let camera: Camera = Camera()
    @Binding var frameDir: String
    @Binding var id: Int
    @Binding var image: NSImage?
    @Binding var isOpendCamera: Bool
    @State private var framesNum: Int = 0
    @State private var sliderValue: CGFloat = 0.0
    @State private var frame: NSImage = NSImage()

    var body: some View {
        VStack {
            HStack {
                Button("Open Folder") {
                    let openPanel = NSOpenPanel()
                    openPanel.allowsMultipleSelection = false
                    openPanel.canChooseDirectories = true
                    openPanel.canChooseFiles = false
                    if openPanel.runModal() == .OK {
                        frameDir = openPanel.url!.absoluteString
                        framesNum = getFileCount()
                        guard let url = URL(string: openPanel.url!.absoluteString + "frame_" + String(id) + ".png"),
                              let newImage = NSImage(contentsOf: url)
                        else { return }
                        image = newImage
                    }
                }
                Text("Directory : " + frameDir)
            }
            .padding()
            Slider(value: $sliderValue, in: 0...1) {
                Text(String(id) + " / " + String(framesNum - 1))
            }
            .onChange(of: sliderValue) {
                id = Int(CGFloat(framesNum - 1) * sliderValue)
                guard let url = URL(string: frameDir + "frame_" + String(id) + ".png"),
                        let newImage = NSImage(contentsOf: url)
                else { return }
                image = newImage
            }
            if isOpendCamera {
                Button("Take a photo") {
                    if frameDir == "" {
                        return
                    }
                    camera.takePhoto(framesDir: frameDir, frame: frame)
                    camera.stop()
                    isOpendCamera = false
                    framesNum = getFileCount()
                    sliderValue = 1.0
                    id = Int(CGFloat(framesNum - 1) * sliderValue)
                    image = frame
                }
                .keyboardShortcut("s")
            }
            else {
                Button("Boot Camera") {
                    if frameDir == "" {
                        return
                    }
                    isOpendCamera = true
                    camera.boot { sampleBuffer in
                        if let nsImage: NSImage = self.NSImageFromSampleBuffer(sampleBuffer) {
                            DispatchQueue.main.async {
                                frame = nsImage
                            }
                        }
                    }
                }
                .keyboardShortcut("b")
            }
        }
    }

    private func getFileCount() -> Int {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: URL(string: frameDir)!, includingPropertiesForKeys: nil)
            return contents.count
        } catch {
            return 0
        }
    }
    
    func NSImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> NSImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            let context = CIContext()
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return NSImage(cgImage: image, size: .zero)
            }
        }
        return nil
    }
    
    
    
//    func NSImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> NSImage? {
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
//            let context = CIContext()
//            if let image = context.createCGImage(ciImage, from: imageRect) {
//                return NSImage(cgImage: image, size: ciImage.extent.size)
//            }
//        }
//    }
//    func UIImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
//            let context = CIContext()
//            if let image = context.createCGImage(ciImage, from: imageRect) {
//                return UIImage(cgImage: image)
//            }
//        }
//        return nil
//    }
}
