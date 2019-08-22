//
//  FileUtilities.swift
//  Drumify
//
//  Created by Jackson Kurtz on 8/22/19.
//  Copyright © 2019 Jackson Kurtz. All rights reserved.
//

import Foundation

class FileUtilities {
    static func copyFileToDocuments(resource: String, type: String) {
        let bundlePath = Bundle.main.path(forResource: resource, ofType: type)
        do {
            let contents = try String(contentsOfFile: bundlePath!)
            print("bundle path contents: ", contents)
        } catch {
            // contents could not be loaded
        }
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent(resource + type)
        let fullDestPathString = fullDestPath!.path
        print(fileManager.fileExists(atPath: bundlePath!)) // prints true
        
        do{
            try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString)
        }catch{
            print("\n")
            print(error)
        }
    }
}


