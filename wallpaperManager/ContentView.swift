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
    @State var imageFiles: [String] = []
    @State var selectedWallpaper: String = "None"
    var body: some View {
        VStack {
            Picker("Screen", selection:$selectedScreen) {
                //self tells swift each element is unique allowing the for each
                ForEach(NSScreen.screens, id: \.self) { screen in
                    Text(screen.localizedName).tag(screen.localizedName)
                }
            } .pickerStyle(.segmented)
                .disabled(allScreens)
            Picker("Wallpaper", selection:$selectedWallpaper) {
                //self tells swift each element is unique allowing the for each
                ForEach(imageFiles, id: \.self) { file in
                    Text(file)
                } .onChange(of: selectedWallpaper) {
                    var status = ""
                    let url = URL(fileURLWithPath:selectedWallpaper)
                    if allScreens == true {
                        for screen in NSScreen.screens {
                            status = setWallpaper(url: url, screen: screen)
                        }
                    } else {
                        let display = getScreenByName(selectedScreen)
                        status = setWallpaper(url: url, screen: display)
                    }
                    print (status)
                }
            } .pickerStyle(.inline)
            Toggle("All screens", isOn:$allScreens)
            Text("Selected screen: \(selectedScreen)" )
            Button("set wallpaper") {
                let display = getScreenByName(selectedScreen)
                manageNewWallpaper(display)
            } .disabled(selectedScreen == "None")
            Button("get wallpapers") {
                parseFolder { (newFiles) in
                    for file in newFiles  {
                        imageFiles.append(file)
                    }
                    print(imageFiles)
                }
            }
        }
        .padding()

    }
}

#Preview {
    ContentView()
}






