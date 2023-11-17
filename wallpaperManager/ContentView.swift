//
//  ContentView.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/17.
//

import SwiftUI


struct ContentView: View {
    @State var selectedScreen: String = getScreenByIndex(1).localizedName
    @State var imageFiles: [String] = []
    @State var selectedWallpaper: String = "None"
    var body: some View {
        VStack {
            Picker("Screen", selection:$selectedScreen) {
                //self tells swift each element is unique allowing the for each
                ForEach(NSScreen.screens, id: \.self) { screen in
                    Text(screen.localizedName).tag(screen.localizedName)
                }
            }
            Picker("Wallpaper", selection:$selectedWallpaper) {
                //self tells swift each element is unique allowing the for each
                ForEach(imageFiles, id: \.self) { file in
                    Text(file)
                } .onChange(of: selectedWallpaper) {
                    let url = URL(fileURLWithPath:selectedWallpaper)
                    let display = getScreenByName(selectedScreen)
                    let status = setWallpaper(url: url, screen: display)
                    print (status)
                }
            }
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
        .pickerStyle(.segmented)
    }
}



#Preview {
    ContentView()
}


let validFileExtensions: Set = [".jpg",".jpeg",".tiff",".gif",".bmp",".pdf",".tif",".png"]


func parseFolder(completionHandler: @escaping ([String]) -> Void)  {
    var files:[String] = []
    chooseFolder { (folder) in
        if let filePath = folder {
            let filteredFiles = getWallpapers(filePath:filePath)
            print("Filtered files:",filteredFiles)
            for file in filteredFiles {
                files.append(file)
            }
            completionHandler(files)
        } else {
            print("Failed to parse folder")
            completionHandler([])
        }
    }

}

func chooseFolder(completionHandler: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false

    openPanel.begin { (result) in
        if result == .OK, let chosenURL = openPanel.url {
            completionHandler(chosenURL)
        } else {
            completionHandler(nil)
        }
    }
}


func getWallpapers(filePath: URL) -> [String] {
        do {
            let directory = filePath.path()
            let files = try FileManager.default.contentsOfDirectory(atPath:directory)
            return filterFiles(fileNames:files, directory: directory)
        }
        catch {
            print(error.localizedDescription)
            return []
        }
    }

func filterFiles(fileNames:[String],directory:String) -> [String] {
    var finalFiles:[String] = []
    for file in fileNames {
        for fileType in validFileExtensions {
            if file.contains(fileType) {
                let fullFilesName = directory+file
                finalFiles.append(fullFilesName)
                break
            }
        }
    }
    return finalFiles
}

//brings up file window to choose one file
func chooseFile(completionHandler: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.allowedContentTypes = [.png,.jpeg,.tiff,.gif,.bmp,.pdf]

    openPanel.begin { (result) in
        if result == .OK, let chosenURL = openPanel.url {
            completionHandler(chosenURL)
        } else {
            completionHandler(nil)
        }
    }
}


func setWallpaper(url:URL, screen:NSScreen) -> String {
    do {
        try NSWorkspace.shared.setDesktopImageURL(url, for:screen)
        return "Set desktop image."
    } catch {
        print(error)
        return "Failed to set wallpaper \(error.localizedDescription)."
    }
}

func getScreenByIndex(_ index:Int) -> NSScreen {
    let screens = NSScreen.screens
    //checks to see for a valid index, if not sets screen to primary (0)
    if index < screens.count {
        return screens[index-1]
    } else {
        return screens[0]
    }
}

func getScreenByName(_ currentDisplay: String) -> NSScreen {
    let screens = NSScreen.screens
    var screenIndex = 0
    for screen in screens {
        if screen.localizedName == currentDisplay {
            return screens[screenIndex]
        }
        screenIndex += 1
    }
    return screens[0] //returns primary if can't find name
}

func manageNewWallpaper(_ display:NSScreen) {
    chooseFile { (result) in
        //if let to continue with the rest of the code conditionally
        if let url = result {
            let status = setWallpaper(url: url, screen: display)
            print(status)
        } else {
            print("Invalid file url result.")
        }
    }
}
