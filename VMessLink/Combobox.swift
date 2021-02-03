//
//  Combobox.swift
//  VMessLink
//
//  Created by 王要正 on 2021/2/3.
//

import AppKit
import SwiftUI

struct Combobox: NSViewRepresentable {

    let options: [String]?
    @Binding var selection: String

    func makeNSView(context: Context) -> NSComboBox {
        let combobox = NSComboBox()
        combobox.stringValue = selection
        combobox.delegate = context.coordinator
        if let options = options {
            combobox.addItems(withObjectValues: options)
        }
        return combobox
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator($selection)
    }

    final class Coordinator: NSObject, NSComboBoxDelegate {
        @Binding var selection: String

        init(_ selection: Binding<String>) {
            self._selection = selection
            super.init()
        }

        func comboBoxSelectionDidChange(_ notification: Notification) {
            guard let combobox = notification.object as? NSComboBox,
                  let value = combobox.objectValueOfSelectedItem as? String else {
                selection = ""
                return
            }
            selection = value
        }
    }
}
