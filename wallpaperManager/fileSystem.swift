//
//  fileSystem.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/18.
//

import Foundation
import SwiftUI

let fileManager = FileManager.default

func readFile() -> String {
    let file = "wallpapers.txt"
    if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appending(path: file)
        if fileManager.fileExists(atPath: fileURL.path()) {
            do {
                let urlStrings = try String(contentsOf: fileURL,encoding: .utf8)
                return urlStrings
            }
            catch {
                print("Couldn't read from file")
            }
        }
    }
    return ""
}

func writeFile(imageURL:URL) {
    let file = "wallpapers.txt"
    let stringToWrite = imageURL.absoluteString+"\n"
    let data = stringToWrite.data(using: .utf8)
    if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appending(path: file)
        if fileManager.fileExists(atPath: fileURL.path()) {
            do {
                if let fileData = data {
                    if let fileHandler = try? FileHandle(forWritingTo: fileURL) {
                        try fileHandler.seekToEnd()
                        try fileHandler.write(contentsOf: fileData)
                        try fileHandler.close()
                        print("wrote to \(fileURL)")
                    }
                } else {
                    print("Couldn't verify the integrity of the image path.")
                }
                
            }
            catch {
                print("Error is \(error)")
            }
        } else {
            print("Created file \(fileURL)")
            fileManager.createFile(atPath: fileURL.path(), contents: data)
        }
        
    }
}

func parseFolder(completionHandler: @escaping ([URL]) -> Void)  {
    var files:[URL] = []
    chooseFilesAndFolders { (urls) in
        for locator in urls {
            if locator.hasDirectoryPath {
                let filteredFiles = getWallpapers(filePath:locator)
                for file in filteredFiles {
                    files.append(file)
                }
            } else {
                files.append(locator)
            }
                
            }
        completionHandler(files)
        }
    }

func chooseFilesAndFolders(completionHandler: @escaping ([URL]) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = true
    openPanel.allowedContentTypes = [.jpeg,.gif,.png,.tiff,.bmp,.pdf]
    
    openPanel.begin { (result) in
        if result == .OK {
            completionHandler(openPanel.urls)
        } else {
            completionHandler([])
        }
    }
}
    
func getWallpapers(filePath: URL) -> [URL] {
    var validUrls:[URL] = []
    do {
        let files = try FileManager.default.contentsOfDirectory(at: filePath, includingPropertiesForKeys: [.pathKey])
        for file in files {
            if validFileExtensions.contains(file.pathExtension) {
                validUrls.append(file)
            }
        }
    }
    catch {
        print(error.localizedDescription)
    }
    return validUrls
}
