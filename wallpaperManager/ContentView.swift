//
//  ContentView.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/17.
//

import SwiftUI
import HotKey


struct ContentView: View {
    @State var selectedScreen: String = getScreenByIndex(1).localizedName
    @State var allScreens: Bool = true
    @State var imageFiles: [URL] = []
    @State var finderOpen: Bool = false
    @State var selectedIndex: Int = -1
    @State var screens = {return NSScreen.screens}()
    
    // Setup hot key for ⌥⌘R
    let rightArrow = HotKey(key: .rightArrow, modifiers: [.command, .option])
    let leftArrow = HotKey(key: .leftArrow, modifiers: [.command, .option])
    
    var body: some View {
        VStack {
            VStack {
                Picker("", selection:$selectedScreen) {
                    //self tells swift each element is unique allowing the for each
                    ForEach(screens, id: \.self) { screen in
                        Text(screen.localizedName).tag(screen.localizedName)
                    }
                }
                .padding(5)
                .fixedSize()
                .disabled(allScreens)
                //self tells swift each element is unique allowing the for each
                if NSScreen.screens.count > 1 {
                    Toggle("All screens", isOn:$allScreens).padding(5)
                }
                HStack {
                    Button("Import wallpapers") {
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
                        .fontWeight(.bold)
                        .padding(10)
                        .buttonStyle(PlainButtonStyle())
                        .background(Color.accentColor.opacity(0.5))
                    Button("Delete all") {
                        imageFiles = []
                        clearFile()
                    } .disabled(finderOpen)
                        .fontWeight(.bold)
                        .padding(10)
                        .buttonStyle(PlainButtonStyle())
                        .background(Color.red.opacity(0.5))
                }.padding(10)
            }
            HStack {
                HStack {
                    Text("Cycle backwards:")
                    Text("⌘⌥←")
                        .fontWeight(.bold)
                        .background(Color.accentColor.opacity(0.5))
                }
                HStack {
                    Text("Cycle Forwards:")
                    Text("⌘⌥→")
                        .fontWeight(.bold)
                        .background(Color.accentColor.opacity(0.5))
                }
                HStack {
                    Text("Toggle window:")
                    Text("⌘⌥↑")
                        .fontWeight(.bold)
                        .background(Color.accentColor.opacity(0.5))
                    
                }
            } .padding(5)
            ScrollView {
               let columns = [GridItem(.adaptive(minimum: 100,maximum: 200))]
               LazyVGrid(columns: columns, spacing: 20) { // Add spacing here
                   ForEach(Array(zip(imageFiles.indices,imageFiles)), id: \.0) { index, imageURL in
                       VStack{
                           Button {
                              selectedIndex = index
                              handleWallpaperChange(allScreens: allScreens, image: imageURL, target: selectedScreen)
                           } label: {
                              let image = getNSImageFromURL(imageURL)
                              Image(nsImage:image)
                                  .resizable()
                                  .frame(width:100,height:100)
                                  .aspectRatio(contentMode: .fill)
                                  .shadow(radius: 10)
                                  .border(index == selectedIndex ? Color.accentColor : Color.clear, width: 1)
                           } .buttonStyle(PlainButtonStyle())
                           Image(systemName: "trash")
                              .foregroundColor(.white)
                              .padding(7)
                              .shadow(radius:5)
                              .background(Color.red)
                              .clipShape(Circle())
                              .onTapGesture {
                                  imageFiles.remove(at: index)
                                  removeURLFromFile(imageURL)
                              }
                           }
                       }
                       .padding() // Add padding here
                   }.padding() // Add padding here
               }
               .frame(minWidth: 400, minHeight:200,maxHeight: 400)
               .background(Color.white.opacity(0.1))
            }
            .padding()
            .onAppear() {
                rightArrow.keyDownHandler = {
                    cycleWallpaper("forward", selectedIndex: &selectedIndex, imageFiles: imageFiles, allScreens: allScreens, target: selectedScreen)
                }
                leftArrow.keyDownHandler = {
                    cycleWallpaper("backward", selectedIndex: &selectedIndex, imageFiles: imageFiles, allScreens: allScreens, target: selectedScreen)
                }
                let urlData = readFile()
                let urlStrings = urlData.components(separatedBy: "\n")
                for string in urlStrings {
                    if string == "" {break}
                    if let currentURL = URL(string:string){
                        imageFiles.append(currentURL)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)) { _ in
                screens = NSScreen.screens
            }
            
        }
    }

#Preview {
    ContentView()
}






