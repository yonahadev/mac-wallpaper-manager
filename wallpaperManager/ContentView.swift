//
//  ContentView.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/17.
//

import SwiftUI


struct ContentView: View {
    @State private var status: String = "Awaiting user input..."
    let imagePath = "/Users/tom/Documents/swift/wallpaperManager/res/john.png"
    var body: some View {
        VStack {
            Text("Manage wallpapers")
            Button("set wallpaper") {
                manageNewWallaper()

            }
            Text(status)
        }
        .padding()
    }
}



#Preview {
    ContentView()
}

//brings up file window to choose one file
func chooseFile(completionHandler: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false

    openPanel.begin { (result) in
        if result == .OK, let chosenURL = openPanel.url {
            completionHandler(chosenURL)
        } else {
            completionHandler(nil)
        }
    }
}

func setWallpaper(url:URL) -> String {
    //guard is for early returning
    guard let screen = NSScreen.main else {return "Failed to find screen."}
    do {
        try NSWorkspace.shared.setDesktopImageURL(url, for:screen)
        return "Set desktop image."
    } catch {
        print(error)
        return "Failed to set wallpaper \(error.localizedDescription)."
    }
}

let manageNewWallaper = {
    chooseFile { (result) in
        //if let to continue with the rest of the code conditionally
        if let url = result {
            let status = setWallpaper(url: url)
            print(status)
        } else {
            print("Invalid file url result.")
        }
    }
}
