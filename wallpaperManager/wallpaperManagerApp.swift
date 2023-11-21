//
//  wallpaperManagerApp.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/17.
//

import SwiftUI
import HotKey

@main
struct wallpaperManagerApp: App {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @State var windowOpen = true
    let toggleHotkey = HotKey(key: .upArrow,modifiers: [.command,.option])
    var body: some Scene {
        WindowGroup("Main Window",id: "mainWindow") {
            ContentView() .onAppear() {
                toggleHotkey.keyDownHandler = {
                    toggleWindow(openWindow: openWindow, dismissWindow: dismissWindow, windowOpen: &windowOpen)
                }
            } .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) {_ in
                windowOpen = false
            }
        }
        MenuBarExtra("Wallpaper Manager",systemImage: "photo.on.rectangle") {
            Button("Launch Wallpaper Manager") {
                toggleWindow(openWindow: openWindow, dismissWindow: dismissWindow, windowOpen: &windowOpen)

                }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
                
            }
        }
    }
}
