//
//  fileSystem.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/18.
//

import Foundation
import SwiftUI

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
            print(file.pathExtension)
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
