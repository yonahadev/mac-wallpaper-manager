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
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 100,maximum: 200))]
                LazyVGrid(columns: columns) {
                    ForEach(Array(zip(imageFiles.indices,imageFiles)), id: \.0) { index, imageURL in
                        VStack{
                            Button {
                                selectedIndex = index
                                do {
                                    if allScreens == true {
                                        for screen in NSScreen.screens {
                                            try setWallpaper(url: imageURL, screen: screen)
                                        }
                                    } else {
                                        let display = getScreenByName(selectedScreen)
                                        try setWallpaper(url: imageURL, screen: display)
                                    }
                                } catch {
                                    print("Error changing wallpaper: \(error)")
                                }
                            } label: {
                                Image(nsImage:{
                                    do {
                                        let imageData = try Data(contentsOf: imageURL)
                                        // Create NSImage from data
                                        if let image = NSImage(data: imageData) {
                                            return image
                                        } else {
                                            print("Failed to create NSImage from data.")
                                            return NSImage()
                                        }
                                    } catch {
                                        // Handle errors while reading file data
                                        print("Error loading image from file: \(error)")
                                        return NSImage()
                                    }
                                }()
                                      
                                )
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
                                    let urlData = readFile()
                                    let urlStrings = urlData.components(separatedBy: "\n")
                                    let remainingURLS = urlStrings.filter { $0 != imageURL.absoluteString}
                                    clearFile()
                                    for locator in remainingURLS {
                                        if let currentURL = URL(string:locator) {
                                            writeFile(imageURL: currentURL)
                                        }
                                    }
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






