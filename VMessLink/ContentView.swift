//
//  ContentView.swift
//  VMessLink
//
//  Created by 王要正 on 2021/2/3.
//

import SwiftUI
import UserNotifications

private let prevStoredKey = "PREV_STORED"

let qrCodeFileUrl: URL = {
    let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
    return tempUrl.appendingPathComponent("vmess-link.qrcode.jpg")
}()

struct ContentView: View {
    @State var fields: [VMessField: String] = [:]
    @State var presentQRCode = false
    @State var qrCodeImage: NSImage?

    var body: some View {
        VStack(alignment: .center) {
            ForEach(VMessField.allCases, id: \.self) { field in
                HStack {
                    Text(field.name)
                        .frame(width: 60, alignment: .trailing)
                    if let options = field.options {
                        Combobox(options: options, selection: self.binding(for: field))
                    } else {
                        TextField("", text: self.binding(for: field))
                    }
                }
            }

            Spacer(minLength: 20)

            HStack {
                Button(action: copyVMessLink, label: {
                    Label("Copy VMess Link", systemImage: "doc.on.clipboard")
                })
                .keyboardShortcut(
                    KeyEquivalent("c"),
                    modifiers: [.command, .shift]
                )

                Button(action: generateQRCode, label: {
                    Label("QRCode Image", systemImage: "qrcode")
                })
                .popover(isPresented: $presentQRCode) {
                    QRCodePreviewView(qrCodeImage: qrCodeImage)
                }
                .keyboardShortcut(
                    KeyEquivalent("i"),
                    modifiers: [.command]
                )
            }
        }
        .padding()
        .fixedSize(horizontal: false, vertical: true)
        .frame(minWidth: 400, maxWidth: 800)
        .navigationTitle("VMess Link Generator")
        .onAppear(perform: {
            prefillFields()
        })
    }

    private func prefillFields() {
        let fillFields: (((VMessField) -> String?)?) -> Void = { valueBlock in
            for field in VMessField.allCases {
                if let value = valueBlock?(field) {
                    fields[field] = value
                } else if let value = field.defaultValue {
                    fields[field] = value
                }
            }
        }

        guard let data = UserDefaults.standard.data(forKey: prevStoredKey) else {
            fillFields(nil)
            return
        }

        let decoder = JSONDecoder()
        do {
            let prevStored = try decoder.decode([String: String].self, from: data)
            fillFields { field -> String? in
                return prevStored[field.rawValue]
            }
        } catch {
            fillFields(nil)
        }
    }

    private func binding(for field: VMessField) -> Binding<String> {
        return .init {
            fields[field, default: ""]
        } set: {
            fields[field] = $0
        }
    }

    private func validateFields() -> Bool {
        var invalidFields: [VMessField] = []
        for field in VMessField.allCases {
            let value = fields[field, default: ""]
            if value.isEmpty {
                invalidFields.append(field)
            }
        }

        guard invalidFields.isEmpty else {
            let fieldNames = invalidFields.map(\.name)
            let fmt = ListFormatter()
            let joinedNames = fmt.string(from: fieldNames) ?? ""
            showAlert(with: "\(joinedNames) could not be empty")
            return false
        }

        return true
    }

    private func vmessLink() throws -> String {
        let encoder = JSONEncoder()

        let info = Dictionary(fields.map { ($0.key.rawValue, $0.value) }) { $1 }
        let data = try encoder.encode(info)
        UserDefaults.standard.setValue(data, forKey: prevStoredKey)
        return "vmess://\(data.base64EncodedString())"
    }

    private func copyVMessLink() {
        guard validateFields() else {
            return
        }

        do {
            let link = try vmessLink()
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            guard pasteboard.setString(link, forType: .string) else {
                showAlert(with: "Copy failed")
                return
            }
            presentNotification(link: link)
        } catch {
            showAlert(with: error.localizedDescription)
        }
    }

    private func generateQRCode() {
        guard validateFields() else {
            return
        }

        guard
            let link = try? vmessLink(),
            let linkData = link.data(using: .ascii),
            let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return
        }
        filter.setValue(linkData, forKey: "inputMessage")

        guard let image = filter.outputImage?.transformed(by: .init(scaleX: 3, y: 3)) else {
            return
        }

        let rep = NSCIImageRep(ciImage: image)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        qrCodeImage = nsImage
        saveQRCodeImage()

        presentQRCode = true
    }

    private func saveQRCodeImage() {
        guard let image = qrCodeImage, let imageData = image.tiffRepresentation else {
            return
        }

        try? imageData.write(to: qrCodeFileUrl)
    }

    private func showAlert(with title: String, message: String? = nil) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        if let message = message {
            alert.informativeText = message
        }
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func presentNotification(link: String) {
        let title = "The VMess Link was copied to your clipboard!"
        let subtitle = "\(link)\nYou can paste it to your v2ray client now!"
        guard !NSApp.isActive else {
            showAlert(with: title, message: subtitle)
            return
        }

        let nc = UNUserNotificationCenter.current()

        let showNotification = {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.sound = .default
            let request = UNNotificationRequest(
                identifier: "copy-success",
                content: content,
                trigger: nil
            )
            nc.add(request)
        }

        nc.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    showNotification()
                }
            case .notDetermined:
                nc.requestAuthorization(options: [.alert, .sound]) { (authorized, _) in
                    if authorized {
                        DispatchQueue.main.async {
                            showNotification()
                        }
                    }
                }
            default: break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
