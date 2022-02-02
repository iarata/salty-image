//
//  Salty_ImageApp.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import PythonKit

@main
struct Salty_ImageApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    @AppStorage(UserStorageName.userUID.rawValue) var userUID: String = ""
    
    // Firebase Init
    init() {
//        Python.version()
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 630, height: 400, alignment: .center)
                .navigationTitle("Salty Image")
                .navigationSubtitle("Build: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)")
                .onAppear {
                    Auth.auth().signInAnonymously { authResult, error in
                        if let user = authResult?.user {
                            self.userUID = user.uid
                        }
                    }
                }
        }
        .windowStyle(DefaultWindowStyle())
        .windowToolbarStyle(DefaultWindowToolbarStyle())
        
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Salty Image") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "This is an free app for learning purposes.",
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.boldSystemFont(
                                        ofSize: NSFont.smallSystemFontSize)
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© \(Calendar.current.component(.year, from: Date())) Hajebrahimi Alireza - UCE.JP"]
                    )
                }
            }
        }
    }
    
//    func hideZoomButton() {
//        for window in NSApplication.shared.windows {
//            window.standardWindowButton(NSWindow.ButtonType.zoomButton)!.isEnabled = false
//        }
//    }
}

