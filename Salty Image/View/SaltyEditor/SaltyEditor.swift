//
//  SaltyEditor.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/11/03.
//

import SwiftUI
import Firebase
import PythonKit

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
    @State var gamma: Double = 0.9
    @State private var screenFieldChangesError = false
    @State private var projectorDistanceChangesError = false
    
    @State private var offsetInDrag: CGFloat = 0
    @State private var viewImagesGeoWidth: CGFloat = 0
    
    @State private var showTransparent = false
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            
            if (self.aspects == nil) {
                VStack {
                    Spacer()
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Text("Building Project...").padding()
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
                                .opacity(self.showTransparent ? 0.5 : 1)
                            
                            Image(nsImage: getImage(urls: self.aspects!.imagesDimensions!, searchString: "Right")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(x: -self.offsetInDrag)
                                .opacity(self.showTransparent ? 0.5 : 1)
                            
                            Spacer()
                        }
                        .onAppear {
                            self.viewImagesGeoWidth = geo.size.width
                            self.offsetInDrag = ((self.viewImagesGeoWidth/2)-((self.aspects!.projectorDistance! * self.viewImagesGeoWidth)/self.aspects!.totalScreenWidth!))/2
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
                                    Label("Softness (Image Edges)", systemImage: "slider.horizontal.below.square.filled.and.square")
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
                                Image(systemName: showTransparent ? "checkmark.square.fill" : "square")
                                            .foregroundColor(showTransparent ? Color(NSColor.systemBlue) : Color.secondary)
                                Text("Transparent")
                                
                                Spacer()
                            }.onTapGesture {
                                withAnimation {
                                    self.showTransparent.toggle()
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
                    withAnimation {
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
                        
                        self.offsetInDrag = ((self.viewImagesGeoWidth/2)-((self.aspects!.projectorDistance! * self.viewImagesGeoWidth)/self.aspects!.totalScreenWidth!))/2
                    }

                }
//                print(Bundle.main.url(forResource:"Pythons/alpha_blending", withExtension: "py")?.path)
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
                        var newURLs:[String] = []
                        for imgURL in self.aspects!.imagesDimensions! {
                            newURLs.append(imgURL.path)
                        }
                        self.loadPython(newURLs,
                                        screenSize: Float(self.totalScreenChanged)!,
                                        projectoDistance: Float(self.projectorsDistanceChanged)!,
                                        softness: Float(self.gamma))
                        
                    }, label: {
                        Image(systemName: "play.fill")
                    })
                    
                })
            }).disabled(self.aspects == nil)
    }
    
    func loadPython(_ images: [String], screenSize: Float, projectoDistance: Float, softness: Float) {
        let sys = Python.import("sys")
//        let os = Python.import("os")
        sys.path.append("\(Bundle.main.bundlePath)/Contents/Resources/")
        let mainStich = Python.import("main_stitch")
        
        
        let ultraSalt = mainStich.MainStitch(images, screenSize, projectoDistance, softness, "\(NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0])")
        print(ultraSalt.process_image())
        
        print("Python \(sys.version_info.major).\(sys.version_info.minor)")
        print("Python Version: \(sys.version)")
        print("Python Encoding: \(sys.getdefaultencoding().upper())")
        print(Bundle.main.bundlePath + "Contents/Resources/")
        let bundle = Bundle.main
        let paths = bundle.paths(forResourcesOfType: nil, inDirectory: nil)
        for path in paths {
            print(path)
        }
        
//        print()
//        os.chdir(os.path.dirname(os.path.abspath(__file__)))
//        print(os.path.dirname(os.path.abspath(__file__))
        
    }
}
