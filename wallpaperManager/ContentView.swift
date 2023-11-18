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
                .fixedSize()
                .disabled(allScreens)
                //self tells swift each element is unique allowing the for each
                ForEach(imageFiles, id: \.self) { file in
                    let url = URL(fileURLWithPath:file)
                    let image = NSImage(byReferencing: url)

                    Button {
                        selectedWallpaper = file
                    } label: {
                        Image(nsImage:image)
                    }
                    Button("Delete") {
                        for imageFile in imageFiles {
                            var index = imageFiles.count-1
                            if imageFile == file {
                                imageFiles.remove(at: index)
                                break
                            }
                            index -= 1
                        }
                    }
                    
                
                .onChange(of: selectedWallpaper) {
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
                    var count: Int = 0
                    var duplicateFiles: [String] = []
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
//                    print(imageFiles)
                    if count != 0 {
                        print("\(count) Duplicate files found",duplicateFiles)
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






