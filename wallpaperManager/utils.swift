//
//  utils.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/18.
//

import Foundation

let validFileExtensions: Set = [".jpg",".jpeg",".tiff",".gif",".bmp",".pdf",".tif",".png"]


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
