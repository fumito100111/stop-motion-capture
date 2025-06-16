//
//  ContentView.swift
//  StopMotionCapture
//
//  Created by Fumito Kimura on 2025/06/16.
//

import SwiftUI

struct ContentView: View {

    @State var frameDir: String = ""
    @State var id: Int = 0
    @State var image: NSImage? = nil
    @State var isOpenedCamera: Bool = false
    @State var isOverlay: Bool = true

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(nsImage: image ?? NSImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                VStack {
                    Spacer()
                    MenuView(frameDir: $frameDir, id: $id, image: $image, isOpendCamera: $isOpenedCamera)
                        .padding(geometry.size.height / 10)
                        .opacity(isOverlay ? 1.0 : 0.0)
                        .onHover { isHover in
                            withAnimation {
                                isOverlay = isHover
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
