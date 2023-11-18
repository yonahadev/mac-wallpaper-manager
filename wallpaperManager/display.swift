//
//  screens.swift
//  wallpaperManager
//
//  Created by tom on 2023/11/18.
//

import Foundation
import SwiftUI

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
