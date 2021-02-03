//
//  ContentView.swift
//  VMessLink
//
//  Created by 王要正 on 2021/2/3.
//

import SwiftUI

private let prevStoredKey = "PREV_STORED"

struct ContentView: View {
    @State var fields: [VMessField: String] = [:]

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

            Button(action: copyVMessLink, label: {
                Label("Copy VMess Link", systemImage: "doc.on.clipboard")
            })
            .keyboardShortcut(
                KeyEquivalent("c"),
                modifiers: [.command, .shift]
            )
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
        let setDefaultValues = {
            for field in VMessField.allCases {
                if let value = field.defaultValue {
                    fields[field] = value
                }
            }
        }

        guard let data = UserDefaults.standard.data(forKey: prevStoredKey) else {
            setDefaultValues()
            return
        }

        let decoder = JSONDecoder()
        do {
            let prevStored = try decoder.decode([String: String].self, from: data)
            for (key, value) in prevStored {
                if let field = VMessField(rawValue: key) {
                    fields[field] = value
                }
            }
        } catch {
            setDefaultValues()
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

    private func copyVMessLink() {
        guard validateFields() else {
            return
        }

        let encoder = JSONEncoder()
        do {
            let info = Dictionary(fields.map { ($0.key.rawValue, $0.value) }) { $1 }
            let data = try encoder.encode(info)
            UserDefaults.standard.setValue(data, forKey: prevStoredKey)
            let link = "vmess://\(data.base64EncodedString())"
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            if !pasteboard.setString(link, forType: .string) {
                showAlert(with: "Copy failed")
            }
        } catch {
            showAlert(with: error.localizedDescription)
        }
    }

    private func showAlert(with message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
