//
//  QRCodePreviewView.swift
//  VMessLink
//
//  Created by 王要正 on 2021/2/24.
//

import SwiftUI

struct QRCodePreviewView: View {
    @Binding var qrCodeImage: NSImage?

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
        } else {
            Text("No QR code image generated")
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

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }
        try? image.tiffRepresentation?.write(to: url)
    }
}

struct QRCodePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodePreviewView(qrCodeImage: .constant(nil))
    }
}
