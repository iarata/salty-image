//
//  SaltyEditor.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/30.
//

import SwiftUI
import Firebase

struct SaltyEditor: View {
    
    @AppStorage(UserStorageName.tempFileURLS.rawValue) var tempURLs = ""
    @AppStorage(UserStorageName.FBProjectName.rawValue) var projectName = ""
    
    @State var saltyManager: SaltyManager
    @State private var aspects: ProjectAspects?
    
    @State var imagesURL: [URL] = []
    
    @State private var showAlert = false
    @State private var alertDetails: SaltyAlert?
    
    @State var imagesSpacing:CGFloat = 0;
    
    // Variables to CHANGE
    @State var totalScreenChanged = ""
    @State var projectorsDistanceChanged = ""
    @State var gamma: Double = 0.0
    @State private var screenFieldChangesError = false
    @State private var projectorDistanceChangesError = false
    
    @State private var offsetInDrag: CGFloat = 0
    @State private var viewImagesGeoWidth: CGFloat = 0
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            
            if (self.aspects == nil) {
                VStack {
                    Spacer()
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Text("Fetching data...")
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    Label("Image Preview", systemImage: "photo")
                    
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Spacer()
                            Image(nsImage: getImage(urls: self.aspects!.imagesDimensions!, searchString: "Left")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(x: self.offsetInDrag)
                            
                            Image(nsImage: getImage(urls: self.aspects!.imagesDimensions!, searchString: "Right")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(x: -self.offsetInDrag)
                            
                            Spacer()
                        }
                        .onReceive(SaltCenter().saltPublisher(name: "updateFirebase")) { outs in
                            print((self.aspects!.projectorDistance! * geo.size.width)/self.aspects!.totalScreenWidth!)
                            print((geo.size.width/2)-((self.aspects!.projectorDistance! * geo.size.width)/self.aspects!.totalScreenWidth!))
                            self.offsetInDrag = ((geo.size.width/2)-((self.aspects!.projectorDistance! * geo.size.width)/self.aspects!.totalScreenWidth!))/2
                        }
                        .onAppear {
                            self.offsetInDrag = ((geo.size.width/2)-((self.aspects!.projectorDistance! * geo.size.width)/self.aspects!.totalScreenWidth!))/2
                        }

                    }
                    Spacer()
                    
                    // Other things
                    HStack(spacing: 25) {
                        
                        VStack(spacing: 12) {
                            // total widht & projector distances
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Screen Width", systemImage: "camera.metering.center.weighted.average")
                                TextField("", text: self.$totalScreenChanged, onEditingChanged: { editing in
                                    if !editing {
                                        if Double(self.totalScreenChanged) != nil && self.totalScreenChanged != "" {
                                            if let val = Double(self.totalScreenChanged) {
                                                db.collection("images").document(self.projectName).updateData(["screenWidth": val])
                                                SaltCenter().saltCall(name: "updateFirebase")
                                            }
                                        }
                                    }
                                })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 200)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Projector Distance", systemImage: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                                TextField("", text: self.$projectorsDistanceChanged, onEditingChanged: { editing in
                                    if !editing {
                                        if Double(self.projectorsDistanceChanged) != nil && self.projectorsDistanceChanged != "" {
                                            if let val = Double(self.projectorsDistanceChanged) {
                                                db.collection("images").document(self.projectName).updateData(["projectorDistance": val])
                                                SaltCenter().saltCall(name: "updateFirebase")
                                            }
                                        }
                                    }
                                })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 200)
                                
                            }
                        }
                        
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Label("Gamma", systemImage: "slider.horizontal.below.square.filled.and.square")
                                    Spacer()
                                    Text(String(format:"%.02f", self.gamma))
                                }
                                HStack {
                                    Text("0")
                                    Slider(value: self.$gamma, in: 0...1, step: 0.01)
                                        .onChange(of: self.gamma) {
                                            db.collection("images").document(self.projectName).updateData(["gamma": $0])
                                        }
                                    Text("1")
                                }
                            }
                            
                            HStack {
                                Spacer()
                                Button {
                                    print("Synced")
                                } label: {
                                    Text("Apply")
                                }

                            }
                        }
                        
                        Spacer()
                    
                    }
                    
                }.padding()
            }
            
            
            
        }.padding()
            .alert(item: $alertDetails, content: { info in
                alert(title: info.title, message: info.message, type: info.id)
            })
        
            .onAppear {
                print(self.tempURLs)
                print(self.projectName)
                db.collection("images").document(self.projectName).addSnapshotListener { documentSnap, error in
                    guard let document = documentSnap else {
                        self.alertDetails = SaltyAlert(id: .error, title: "Error", message: error!.localizedDescription)
                        return
                    }
                    guard let data = document.data() else {
                        self.alertDetails = SaltyAlert(id: .error, title: "Error", message: "Document was empty!")
                        return
                    }
                    self.aspects = ProjectAspects(self.projectName,
                                                  data["screenWidth"] as! Double,
                                                  data["projectorDistance"] as! Double,
                                                  convertStringToURLs(string: self.tempURLs))
                    self.saltyManager = SaltyManager(paths: self.tempURLs, aspects: self.aspects!)
                    
                    self.totalScreenChanged = "\(data["screenWidth"] as! Double)"
                    self.projectorsDistanceChanged = "\(data["projectorDistance"] as! Double)"
                    self.gamma = data["gamma"] as! Double

                }
            }
        
        
        
        // toolbar
            .toolbar(content: {
                
                ToolbarItemGroup(placement: ToolbarItemPlacement.automatic, content: {
                    Button {
                        self.alertDetails = SaltyAlert(id: .deleteProject, title: "Confirmation", message: "Are you sure that you want to delete all data?")
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    
                    Button(action: {
                        print("Ascsa")
                    }, label: {
                        Image(systemName: "play.fill")
                    })
                    
                })
            })
    }
}
