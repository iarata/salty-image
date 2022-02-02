//
//  InitialSheetNetwork.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/28.
//

import SwiftUI

struct InitialSheetNetwork: View {
    @State var projectName = ""
    @State var showAlert = false
    @State var alertMessage = ""
    
    @Binding var showConnect: Bool
    @State var isLoading = false
    
    @AppStorage(UserStorageName.tempFileURLS.rawValue) var tempFileURLS = ""
    @AppStorage(UserStorageName.FBProjectName.rawValue) var projectUSERDB = ""
    
    var body: some View {
        VStack {
            // title
            HStack {
                
                Image(systemName: "network").font(.system(size: 14))
                Text("Load Project").font(.system(size: 16)).bold()
                Spacer()
                if self.isLoading {
                    ProgressView().scaleEffect(0.6, anchor: .center).progressViewStyle(CircularProgressViewStyle()).frame(width: 24, height: 20)
                }
            }.padding([.horizontal, .top])
            Divider()
            HStack {
                Text("Project name:")
                SaltField("SaltyProject", text: self.$projectName)
            }.padding()
            
            Spacer()
            HStack {
                Button("Cancel") {
                    self.showConnect = false
                }.keyboardShortcut(.cancelAction)
                    .disabled(false)
                
                Spacer()
                Button(action: {
                    if self.projectName != "" {
                        self.isLoading = true
                        FBManager().downloadFilesFromFirebaseStorage(folderName: self.projectName) { result, cacheURLs, resCount, error in
                            if let error = error {
                                self.alertMessage = error
                                self.showAlert = true
                                self.isLoading = false
                            } else {
                                if let cacheURLs = cacheURLs {
                                    if cacheURLs.count == resCount! {
                                        projectUSERDB = projectName
                                        tempFileURLS = "\(cacheURLs)"
                                        SaltCenter().saltCall(name: "NetworLoaded")
                                    }
                                }
                            }
                            
                        }
                    } else {
                        self.alertMessage = "Please enter a project name."
                        self.showAlert = true
                    }
                }) {
                    Text("Connect")
                }.keyboardShortcut(.defaultAction)
            }.padding(.horizontal)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .frame(width: 300, height: 40)
            
        }.disabled(self.isLoading)
    }
}
