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
    @State var finderOpen: Bool = false
    @State var selectedIndex: Int = -1
        
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
            Toggle("All screens", isOn:$allScreens)
            Button("get wallpapers") {
                finderOpen = true
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
                            writeFile(imageURL: file)
                        }
                    }
                    finderOpen = false
                }
            }  .disabled(finderOpen)
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 100,maximum: 200))]
                LazyVGrid(columns: columns) {
                    ForEach(Array(zip(imageFiles.indices,imageFiles)), id: \.0) { index, file in
                        let image = NSImage(byReferencing: file)
                        Button {
                            selectedIndex = index
                            do {
                                if allScreens == true {
                                    for screen in NSScreen.screens {
                                        try setWallpaper(url: file, screen: screen)
                                    }
                                } else {
                                    let display = getScreenByName(selectedScreen)
                                    try setWallpaper(url: file, screen: display)
                                }
                            } catch {
                                print("Error changing wallpaper: \(error)")
                            }
                        } label: {
                            Image(nsImage:image)
                                .resizable()
                                .frame(width:75,height:75)
                                .aspectRatio(contentMode: .fit)
                                .border(index == selectedIndex ? Color.accentColor : Color.gray, width: 2)
                        } .buttonStyle(PlainButtonStyle())
                        Button("Delete") {
                            imageFiles.remove(at: index)
                        }
                    }
                }
            }.frame(maxWidth: 800,maxHeight:300)
                .background(Color.white)
                .opacity(0.3)
                .padding()
        }
        .background(LinearGradient(colors: [.pink,.black], startPoint: .leading, endPoint: .trailing))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}






