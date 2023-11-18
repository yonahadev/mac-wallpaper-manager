//
//  fileSystem.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/18.
//

import Foundation
import SwiftUI

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
