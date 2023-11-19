//
//  ContentView.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/17.
//

import SwiftUI


struct ContentView: View {
    @State var selectedScreen: String = getScreenByIndex(1).localizedName
    @State var allScreens: Bool = false
    @State var imageFiles: [URL] = []
    let workspace = NSWorkspace.shared
    @State var selectedWallpaper: URL = {
        if let existingWallpaper = NSWorkspace.shared.desktopImageURL(for: getScreenByIndex(1)) {
            return existingWallpaper
        } else {
            fatalError("No existing wallpaper set")
        }
    }()
        
    var body: some View {
        VStack {
            Picker("Screen", selection:$selectedScreen) {
                //self tells swift each element is unique allowing the for each
                ForEach(NSScreen.screens, id: \.self) { screen in
                    Text(screen.localizedName).tag(screen.localizedName)
                }
            } .pickerStyle(.segmented)
                .fixedSize()
                .disabled(allScreens)
                //self tells swift each element is unique allowing the for each
            Picker("Wallpaper", selection: $selectedWallpaper) {
                ForEach(imageFiles, id: \.self) { file in
                    let image = NSImage(byReferencing: file)
                    Image(nsImage:image)
                        .resizable()
                        .frame(width:50,height:50)
                }
                .onChange(of: selectedWallpaper) {
                    do {
                            if allScreens == true {
                                for screen in NSScreen.screens {
                                    try setWallpaper(url: selectedWallpaper, screen: screen)
                                }
                            } else {
                                let display = getScreenByName(selectedScreen)
                                try setWallpaper(url: selectedWallpaper, screen: display)
                            }
                    } catch {
                        print("Error changing wallpaper: \(error)")
                    }
                }
            }
            Toggle("All screens", isOn:$allScreens)
            Text("Selected screen: \(selectedScreen)" )
            Button("get wallpapers") {
                parseFolder { (newFiles) in
                    var count: Int = 0
                    var duplicateFiles: [URL] = []
                    for file in newFiles  {
                        var newFile = true
                        for existingImage in imageFiles {
                            if file == existingImage {
                                count+=1
                                duplicateFiles.append(file)
                                newFile = false
                                
                            }
                        }
                        if newFile {
                            imageFiles.append(file)
                        }
                    }
                }
            }
        }
        .padding()

    }
}

#Preview {
    ContentView()
}






