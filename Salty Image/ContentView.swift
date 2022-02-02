//
//  ContentView.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var saltyManager = SaltyManager()
    @AppStorage("documentName") var documentName: String = ""
    
    var body: some View {
        
        Group {
            if self.saltyManager.dataInitiated {
                SaltyEditor(saltyManager: self.saltyManager)
            } else {
                InitSalt(saltyManager: self.saltyManager)
            }
        }
        
        // After uploading to firebase
        .onReceive(SaltCenter().saltPublisher(name: "dataIsSet")) { output in
            withAnimation {
                self.saltyManager.dataInitiated = true
            }
        }
        
        // After loading from network
        .onReceive(SaltCenter().saltPublisher(name: "NetworLoaded")) { output in
            withAnimation {
                self.saltyManager.dataInitiated = true
            }
        }
        
        .onReceive(SaltCenter().saltPublisher(name: "dataUnSet")) { output in
            withAnimation {
                self.saltyManager.dataInitiated = false
                print(documentName)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
