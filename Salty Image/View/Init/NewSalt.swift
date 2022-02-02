//
//  NewSalt.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/27.
//

import SwiftUI

struct NewSalt: View {
    
    @Binding var projectName: String
    @Binding var screenWidth: String
    @Binding var projectDistance: String
    @Binding var imagesDimensions: [URL]
        
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Label("Project Name", systemImage: "shippingbox.fill")
                SaltField("Salty Project", text: self.$projectName)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Label("Screen Width", systemImage: "camera.metering.center.weighted.average")
                    SaltField("Enter width", text: self.$screenWidth, true)
                }
                    
                
                VStack(alignment: .leading) {
                    Label("Projector Distance", systemImage: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                    SaltField("Projectors's Distance", text: self.$projectDistance, true)
                }
            }
            
            Label("Images Daimention", systemImage: "arrow.left.and.right").padding(.top, 5).padding(.bottom, 2)
            
            ForEach (imagesDimensions, id: \.self) { img in
                HStack {
                    Text("\(img.lastPathComponent)").bold()
                    Spacer()
                    Text("\(dToS(NSImage(contentsOf: img)!.size.width, 1))x\(dToS(NSImage(contentsOf: img)!.size.height, 1))")
                }
            }
        }
    }

    func dToS(_ d: Double, _ precision: Int) -> String {
        return String(format: "%." + String(precision) + "f", d)
    }
}
