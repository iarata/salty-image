//
//  FirebaseManager.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/25.
//

import Foundation
import Firebase
import FirebaseStorage

class FBManager {
    
    let collectionName = "images"
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    func syncDB(aspects: ProjectAspects, projectName: String) {
        let db = Firestore.firestore()
        
        db.collection(collectionName).document(projectName).setData([
            "project": aspects.projectName ?? "",
            "screenWidth": aspects.totalScreenWidth ?? 0.0,
            "images": "storageDBURLs"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
    }
    
    // Define a function to add new dictionary to Firestore database and if an array of URLs are giving, upload them to Firebase Storage and add the download URLs to the new dictionary.
    func addToFirestore(dictionary: [String: Any], urls: [URL]) {
        let ref = db.collection("images")
        let project = dictionary["name"] as! String
        var newDict = dictionary
        newDict["gamma"] = 0.0
        ref.document(project).setData(newDict, merge: true) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(project)")
                SaltCenter().saltCall(name: "dataIsSet")
                
            }
        }
        
        
    }
    
    // Upload an array of URLs to Firebase Storage with completion handler and return if process was successful or not.
    func uploadFiles(directory: String, urls: [URL], completion: @escaping (Bool) -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var success = true
        var uploadedFiles = 0
        for url in urls {
            let filePath = directory + "/" + url.lastPathComponent
            let storageRef2 = storageRef.child(filePath)
            storageRef2.putFile(from: url, metadata: nil) { metadata, error in
                if let error = error {
                    print(error.localizedDescription)
                    success = false
                } else {
                    print("[INFO] Uploaded Successfully.")
                    uploadedFiles += 1
                }
            }
        }
        //        SaltCenter().saltCall(name: "dataUploaded")
        if uploadedFiles == urls.count {
            SaltCenter().saltCall(name: "dataUploaded")
        }
        completion(success)
    }
    
    
    // Upload an array of URLs to Firebase Storage with completion handler using DispatchGroup.
    func uploadFilesWithDispatchGroup(directory: String, urls: [URL], completion: @escaping (Bool) -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let group = DispatchGroup()
        var success = true
        for url in urls {
            let filePath = directory + "/" + url.lastPathComponent
            let storageRef2 = storageRef.child(filePath)
            group.enter()
            storageRef2.putFile(from: url, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                    success = false
                } else {
                    storageRef2.downloadURL { url, error in
                        if let error = error {
                            print(error)
                            success = false
                        } else {
                            let downloadURL = self.urlToString(url: url!)
                            print(downloadURL)
                        }
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            completion(success)
        }
    }
    
    
    // Get download link of all files in a folder with given name from Firebase Storage.
    func updateImageLinks(document: String) {
        var downloadLinks: [String] = []
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let ref2 = db.collection(collectionName).document(document)
        let folderPath = ref2.documentID + "/"
        let folderRef = storageRef.child(folderPath)
        folderRef.listAll { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for item in result.items {
                    item.downloadURL { url, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            downloadLinks.append(self.urlToString(url: url!))
                        }
                    }
                }
            }
        }
        print(downloadLinks)
        ref2.setData(["images": downloadLinks], merge: true)
        SaltCenter().saltCall(name: "dataIsSet")
    }
    
    
    // Save images temp.
    func saveTemp(directory: String, urls: [String]) -> [URL] {
        var urls: [URL] = []
        let storage = Storage.storage()
        let storageRef = storage.reference()
        for url in urls {
            let fileName = urlToString(url: url)
            let filePath = directory + "/"
            let storageRef2 = storageRef.child(filePath)
            let localFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            storageRef2.write(toFile: localFile) { url, error in
                if let error = error {
                    print(error)
                } else {
                    urls.append(localFile)
                }
            }
        }
        return urls
    }
    
    // Download files from Firebase Storage and save them temporarily in the app's sandbox and then return the array of URLs, completion by using DispatchGroup.
    
    // ---- NEW ----
    func saveTempFromFB(folderName: String, completion: @escaping ([URL], Bool, String) -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let folderPath = folderName
        let folderRef = storageRef.child(folderPath)
        let tempDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        var success = true
        var errorMsg = ""
        var urls: [URL] = []
        DispatchQueue.global(qos: .userInteractive).sync {
            folderRef.listAll { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                    success = false
                    errorMsg = error.localizedDescription
                } else {
                    if !result.items.isEmpty {
                        for item in result.items {
                            let tempDirURL = tempDir.appendingPathComponent("\(folderName)/\(item.name)")
                            item.write(toFile: tempDirURL) { resURL, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    success = false
                                    errorMsg = error.localizedDescription
                                } else {
                                    print(resURL!)
                                    urls.append(resURL!)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        DispatchQueue.main.async {
            completion(urls, success, errorMsg)
        }
    }
          
    func downloadFilesFromFirebaseStorage(folderName: String, completionHandler: @escaping (Bool, [URL]?, Int?, String?) -> ()) {
        // Create a reference to the file you want to download
        let storageRef = Storage.storage().reference().child(folderName)
        // Create a reference to the file you want to download
        let localFile = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        // Create a DispatchSemaphore to block the current thread until the download is finished
        let semaphore = DispatchSemaphore(value: 2)
        // Create a DispatchQueue to run the download task
        let queue = DispatchQueue(label: "Download queue", qos: .userInitiated)
        // Create a download task
        var cacheURLs: [URL] = []
        
        queue.async {
            storageRef.listAll { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    completionHandler(false, nil, nil, error.localizedDescription)
                } else {
                    if !result.items.isEmpty {
                        for item in result.items {
                            item.write(toFile: localFile.appendingPathComponent("\(folderName)/\(item.name)")) { localURL, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    completionHandler(false, nil, nil, error.localizedDescription)
                                } else {
                                    cacheURLs.append(localURL!)
                                    completionHandler(true, cacheURLs, result.items.count, nil)
                                }
                            }
                        }
                    } else {
                        completionHandler(false, nil, nil, "Project Doesn't exist.")
                    }
                }
                
                semaphore.signal()
            }
        }
        // Wait until the download is finished
        _ = semaphore.wait(timeout: .distantFuture)
    }

    // make a temporary director and save a given file to it.
    func saveFileToTempFolder(url: URL, fileName: String) -> URL {
        let tempDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tempDirURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: url, to: tempDirURL)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return tempDirURL
    }
    
    
    
    // Check if a given folder name exist in Firebase Storage.
    func checkIfDocumentExist(name: String) -> Bool {
        let db = Firestore.firestore()
        let ref = db.collection(self.collectionName).document(name)
        var exist = true
        ref.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
                exist = false
            } else {
                exist = true
            }
        }
        return exist
    }
    
    func urlToString(url: URL) -> String {
        return url.absoluteString
    }
}
