//
//  utils.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/18.
//

import Foundation
import SwiftUI

let validFileExtensions: Set = ["jpg","jpeg","tiff","gif","bmp","pdf","tif","png"]

func handleWallpaperChange(allScreens:Bool,image: URL, target: String) {
    do {
        if allScreens == true {
            for screen in NSScreen.screens {
                try setWallpaper(url: image, screen: screen)
            }
        } else {
            let display = getScreenByName(target)
            try setWallpaper(url: image, screen: display)
        }
    } catch {
        print("Error changing wallpaper: \(error)")
    }
}

func getNSImageFromURL(_ imageURL: URL) -> NSImage {
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
}

func setWallpaper(url:URL, screen:NSScreen) throws {
    do {
        try NSWorkspace.shared.setDesktopImageURL(url, for:screen)
    } catch {
        throw error
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
