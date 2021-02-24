//
//  QRCodePreviewView.swift
//  VMessLink
//
//  Created by 王要正 on 2021/2/24.
//

import SwiftUI

struct QRCodePreviewView: View {
    let qrCodeImage: NSImage?

    var body: some View {
        if let image = qrCodeImage {
            VStack {
                Image(nsImage: image)
                    .onDrag {
                        guard let provider = NSItemProvider(contentsOf: qrCodeFileUrl) else {
                            return NSItemProvider(object: qrCodeFileUrl as NSURL)
                        }
                        return provider
                    }

                Button("Save Image") {
                    saveQRCodeImage()
                }
            }
            .padding()
        }
    }

    private func saveQRCodeImage() {
        guard let image = qrCodeImage else {
            return
        }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "qrcode.jpg"
        panel.runModal()

        guard let url = panel.url else {
            return
        }
        try? image.tiffRepresentation?.write(to: url)
    }
}

struct QRCodePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodePreviewView(qrCodeImage: nil)
    }
}
