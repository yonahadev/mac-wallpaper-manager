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
            VStack {
                Picker("", selection:$selectedScreen) {
                    //self tells swift each element is unique allowing the for each
                    ForEach(NSScreen.screens, id: \.self) { screen in
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
                    .padding(10)
                    .buttonStyle(PlainButtonStyle())
                    .background(.blue)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 5,
                            bottomLeadingRadius: 5,
                            bottomTrailingRadius: 5,
                            topTrailingRadius: 5
                        )
                    )
            }.padding(10)
            HStack {
                Button("Wallpaper back") {
                    if selectedIndex == -1 {
                        selectedIndex = 0
                    } else if selectedIndex == 0 {
                        selectedIndex = imageFiles.count-1
                    } else {
                        selectedIndex -= 1
                    }
                    handleWallpaperChange(allScreens: allScreens, image: imageFiles[selectedIndex], target: selectedScreen)
                } .keyboardShortcut(.leftArrow,modifiers: [.shift,.option])
                Button("Wallpaper forward") {
                    if selectedIndex == -1 {
                        selectedIndex = 0
                    } else if selectedIndex == imageFiles.count-1 {
                        selectedIndex = 0
                    } else {
                        selectedIndex += 1
                    }
                    handleWallpaperChange(allScreens: allScreens, image: imageFiles[selectedIndex], target: selectedScreen)
                } .keyboardShortcut(.rightArrow,modifiers: [.shift,.option])
            }
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 100,maximum: 200))]
                LazyVGrid(columns: columns) {
                    ForEach(Array(zip(imageFiles.indices,imageFiles)), id: \.0) { index, imageURL in
                        VStack{
                            Button {
                                selectedIndex = index
                                handleWallpaperChange(allScreens: allScreens, image: imageURL, target: selectedScreen)
                            } label: {
                                let image = getNSImageFromURL(imageURL)
                                Image(nsImage:image)
                                    .resizable()
                                    .frame(width:75,height:75)
                                    .aspectRatio(contentMode: .fit)
                                    .border(index == selectedIndex ? Color.accentColor : Color.clear, width: 1)
                            } .buttonStyle(PlainButtonStyle())
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Color.red)
                                .clipShape(Circle())
                                .onTapGesture {
                                    imageFiles.remove(at: index)
                                    removeURLFromFile(imageURL)
                                }
                        }
                        }
                    } .padding()
                } .frame(minWidth: 400, minHeight:200,maxHeight: 400)
                    .background(Color.white.opacity(0.1))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .onAppear() {
                let urlData = readFile()
                let urlStrings = urlData.components(separatedBy: "\n")
                for string in urlStrings {
                    if string == "" {break}
                    if let currentURL = URL(string:string){
                        imageFiles.append(currentURL)
                    }
                }
            }
        }
}

#Preview {
    ContentView()
}






