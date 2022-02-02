//
//  SaltyManager.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/25.
//

import Foundation
import SwiftUI

// Salty Manager
class SaltyManager: ObservableObject {
    @Published var imagePaths: String?
    @Published var projectAspects: ProjectAspects?
    @Published var dataInitiated = false
    
    // init
    init(paths: String, aspects: ProjectAspects) {
        self.imagePaths     = paths
        self.projectAspects = aspects
    }
    
    init() {
        
    }
    
    func load() -> [URL]? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes     = []
        panel.canChooseDirectories    = false
        panel.canCreateDirectories    = false
        panel.allowedContentTypes     = [.png, .jpeg]
        panel.title = "Saly Picker"
        if panel.runModal() == .OK {
            return panel.urls
        } else {
            return nil
        }
    }
    
    // Convert an array to one string
    func urlsToString(urls: [URL], seperator: String) -> String {
        var string = ""
        for url in urls {
            string += url.absoluteString + seperator
        }
        return string
    }
    
    
    // Define a function to make a directory with a given name in app's cache folder and copy an array of URLs to the directory with completion handler.
    func copyFilesToCacheFolder(folderName: String, files: [URL], completionHandler: @escaping (Bool, [URL]) -> ()) {
        var finalURLs: [URL] = []
        // Create a reference to the file you want to download
        let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = cacheFolder.appendingPathComponent(folderName)
        // Create a DispatchQueue to run the copy task
        let queue = DispatchQueue(label: "Copy queue")
        // Create a DispatchSemaphore to block the current thread until the copy is finished
        let semaphore = DispatchSemaphore(value: 0)
        var result = true
        // Create a copy task
        queue.sync {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            } catch {
                result = false
            }
            for file in files {
                do {
                    try FileManager.default.copyItem(at: file, to: folder.appendingPathComponent(file.lastPathComponent))
                    finalURLs.append(folder.appendingPathComponent(file.lastPathComponent))
                } catch {
                    result = false
                }
                
            }
            
            // Signal the semaphore
            semaphore.signal()
        }
        // Wait until the semaphore is finished
        _ = semaphore.wait(timeout: .distantFuture)
        // Return the result
        completionHandler(result, finalURLs)
    }
    
    
    // Check if a given folder name exist in app's cache folder.
    func isFolderExist(folderName: String) -> Bool {
        // Create a reference to the file you want to download
        let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = cacheFolder.appendingPathComponent(folderName)
        // Return the result
        return FileManager.default.fileExists(atPath: folder.path)
    }
    
    
   
}

// User Storage Structs
enum UserStorageName: String {
    case leftImagePath = "leftImagePath"
    case rightImagePath = "rightImagePath"
    case FBProjectName = "FBProjectName"
    case userUID = "userUID"
    case tempFileURLS = "tempFileURLS"
    case isDataLoaded = "isDataLoaded"
}
