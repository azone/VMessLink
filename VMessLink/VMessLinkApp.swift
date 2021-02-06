//
//  VMessLinkApp.swift
//  VMessLink
//
//  Created by 王要正 on 2021/2/3.
//

import SwiftUI

@main
struct VMessLinkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: {})
        }
    }
}
