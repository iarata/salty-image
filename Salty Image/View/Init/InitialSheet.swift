//
//  InitialSheet.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/27.
//

import SwiftUI

struct InitialSheet: View {
    @AppStorage("documentName") var documentName: String = ""
    @AppStorage(UserStorageName.tempFileURLS.rawValue) var tempFileURLs = ""
    
    @Binding var isVisible: Bool
    @Binding var items: Array<NSItemProvider>
    @Binding var fbManager: FBManager
    
    @Binding var saltyManager: SaltyManager
    
    @State var projectDetails = ProjectAspects()
    
    // Project Info's
    @State var projectName = ""
    @State var screenWidth = ""
    @State var projectDistance = ""
    @State var imagesDimensions = [URL]()
    
    // Error Alert
    @State var showErrorAlert = false
    @State var errorMsg = "Please enter all details."
    
    // SHEET DISABLE
    @State var isDisabled = false
    
    @AppStorage(UserStorageName.FBProjectName.rawValue) var projectNameStorage = ""
    
    var body: some View {
        VStack (alignment: .leading) {
            
            // title
            HStack {
                Image(systemName: "wand.and.stars").font(.system(size: 14))
                Text("New Project").font(.system(size: 16)).bold()
                Spacer()
                if self.isDisabled { ProgressView().scaleEffect(0.6, anchor: .center).progressViewStyle(CircularProgressViewStyle()).frame(width: 24, height: 20) }
            }.padding(.bottom, 4).padding(.horizontal)
            
            Divider()
            
            NewSalt(projectName: self.$projectName,
                    screenWidth: self.$screenWidth,
                    projectDistance: self.$projectDistance,
                    imagesDimensions: self.$imagesDimensions)
                .padding(.vertical, 5).padding(.horizontal)
            
            Spacer()
            HStack {
                Button("Cancel") {
                    self.isVisible = false
                }.keyboardShortcut(.cancelAction)
                Spacer()
                
                Button(action: {
                    withAnimation {
                       createProject()
                    }
                }, label: {
                    Text("Create").padding(.horizontal)
                })
                    .keyboardShortcut(.defaultAction)
            }.padding()
        }
        .frame(minWidth: 330, minHeight: 280)
        .padding(.top)
        .onAppear {
            for item in items {
                if let identifier = item.registeredTypeIdentifiers.first {
                    if identifier == "public.url" || identifier == "public.file-url" {
                        item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
                            DispatchQueue.main.async {
                                if let urlData = urlData as? Data {
                                    let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                                    self.imagesDimensions.append(urll)
                                }
                            }
                        }
                    }
                }
            }
        }
        .alert(isPresented: self.$showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMsg), dismissButton: .default(Text("OK")))
        }
        .disabled(self.isDisabled)
    }
    
    
    // create project function
    func createProject() {
        if self.projectName != "" && self.screenWidth != "" && self.projectDistance != "" && !imagesDimensions.isEmpty {
            self.projectDetails = ProjectAspects(self.projectName, Double(self.screenWidth)!, Double(self.projectDistance)!, self.imagesDimensions)
         
            let newDict: [String:Any] = [
                "name": self.projectName,
                "screenWidth": Double(self.screenWidth) ?? 0.0,
                "projectorDistance": Double(self.projectDistance) ?? 0.0,
                
            ]
            self.projectNameStorage = self.projectName
            self.documentName = self.projectName
            self.isDisabled = true
            self.fbManager.uploadFilesWithDispatchGroup(directory: newDict["name"] as! String, urls: self.imagesDimensions) { result in
                if result {
                    self.fbManager.addToFirestore(dictionary: newDict, urls: self.imagesDimensions)
                    self.saltyManager.copyFilesToCacheFolder(folderName: newDict["name"] as! String, files: self.imagesDimensions) { result, cacheURL in
                        if result {
                            self.tempFileURLs = "\(cacheURL)"
                        } else {
                            self.errorMsg = "Unable to copy files to cache folder. Please load the project from network now with project name of '\(newDict["name"] as! String).'"
                            self.showErrorAlert = true
                        }
                    }
                    self.isVisible = false
                }
            }
            
        } else {
            self.showErrorAlert = true
        }
    }
    
}
