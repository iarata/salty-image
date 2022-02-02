//
//  Extenstions.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/27.
//

import Foundation
import SwiftUI

extension Date {
    func currentStamp() -> String {
        return String(self.timeIntervalSince1970)
    }
}

extension String {
    func doubleToString(d: Double, precision: Int) -> String {
        return String(format: "%." + String(precision) + "f", d)
    }
    
}

extension View {
    
    // Define a function that has title, message, type that returns a SwiftUI Alert based on the parameters.
    func alert(title: String, message: String, type: SaltyAlert.AlertType) -> Alert {
        switch type {
        case .deleteProject:
            return Alert(title: Text(title), message: Text(message), primaryButton: .destructive(Text("Delete"), action: {
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                SaltCenter().saltCall(name: "dataUnSet")
                
            }), secondaryButton: .cancel())
        case .error:
            return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        case .confirm:
            return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        }
    }
    
    // to an array of URLs.
    func convertStringToURLs(string: String) -> [URL] {
        var urls = [URL]()
        let array = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").components(separatedBy: ",")
        for url in array {
            urls.append(URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }
        return urls
    }
    
    // Return the URL that contains the word.
    func urlBasedOn(urls: String, contains: String) -> String {
        let firstStringArray = convertStringToURLs(string: urls)
        for url in firstStringArray {
            if url.lastPathComponent.contains(contains) {
                return url.path
            }
        }
        return ""
    }

    
    // Use SwiftUI to display a given image from app's cache folder.
    func imageFromCache(folderName: String, fileName: String) -> Image {
        let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = cacheFolder.appendingPathComponent(folderName)
        let image = Image(nsImage: NSImage(contentsOfFile: folder.appendingPathComponent(fileName).path)!)
        return image
    }
    
    // Define a function that takes a an array of URLs and a string and returns nsImage objects of the URL that contains the string.
    func getImage(urls: [URL], searchString: String) -> NSImage? {
        var image: NSImage?
        for url in urls {
            if url.lastPathComponent.contains(searchString) {
                image = NSImage(contentsOfFile: url.path)!
            }
        }
        return image
    }
}
