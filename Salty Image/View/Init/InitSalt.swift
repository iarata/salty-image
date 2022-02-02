//
//  Init.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/25.
//

import SwiftUI

struct InitSalt: View {
    
    @State var saltyManager: SaltyManager
    @State var fbManager = FBManager()
    
    @State var showInitialSheeet = false
    @State var showInitialNetwork = false
    @State var imagesPath        = [NSItemProvider]()
    
    var body: some View {
        VStack {
            Spacer()
            Group {
                Text("Drag and drop image(s) in here or press the ")+Text(Image(systemName: "plus"))+Text(" button.")
            }
            .font(.system(size: 20, weight: .regular, design: .default))
            .foregroundColor(.gray)
            .padding(.bottom)
            
            HStack {
                Image(systemName: "info.circle.fill").foregroundColor(.blue.opacity(0.9))
                Text("For multiple images make sure the name contains ")+Text("left").bold()+Text(" and ")+Text("right").bold()+Text(" words respectively.")
            }
            
            .padding()
            .background(Color.blue.opacity(0.15))
            .cornerRadius(12)
            
            Spacer()
        }
        
        // drop actions
        .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) in
            
            if items != [] {
                self.imagesPath = items
                self.showInitialSheeet = true
                return true
            } else {
                return false
            }
                    
        }
        
        // toolbar
        .toolbar(content: {
            
            ToolbarItemGroup(placement: ToolbarItemPlacement.automatic, content: {
                Button {
                    self.showInitialNetwork = true
                } label: {
                    Image(systemName: "network")
                }
                
                Button(action: {
                    withAnimation {
                        let pathes = self.saltyManager.load()
                        if let saltyURLS = pathes {
                            if saltyURLS != [] {
                                self.imagesPath = urlsToNSItemProviders(urls: saltyURLS)
                                self.showInitialSheeet = true
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "plus")
                })
                
            })
        })
        
        // initial sheet
        .sheet(isPresented: self.$showInitialSheeet) {
            InitialSheet(isVisible: self.$showInitialSheeet, items: self.$imagesPath, fbManager: self.$fbManager, saltyManager: self.$saltyManager)
        }
        
        .sheet(isPresented: self.$showInitialNetwork) {
            InitialSheetNetwork(showConnect: self.$showInitialNetwork)
        }
        
    }
}
