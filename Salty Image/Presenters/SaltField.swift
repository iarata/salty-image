//
//  SaltField.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/27.
//

import SwiftUI

public struct SaltField: View {
    var titleKey: LocalizedStringKey
    @Binding var text: String
    @State var isNumeric: Bool
    
    // local
    @State var errorType = false
    
    /// Whether the user is focused on this `TextField`.
    @State private var isEditing: Bool = false
    
    public init(_ titleKey: LocalizedStringKey, text: Binding<String>, _ isNumeric: Bool = false) {
        self.titleKey = titleKey
        self._text = text
        self.isNumeric = isNumeric
    }
    
    public var body: some View {
        TextField(titleKey, text: $text, onEditingChanged: {
            isEditing = $0
            if Double(self.text) == nil && isNumeric && self.text != "" {
                errorType = true
            } else {
                errorType = false
            }
        })
            .textFieldStyle(RoundedBorderTextFieldStyle())
        if errorType && isNumeric {
            Text("Only double or integers").foregroundColor(.red).font(.footnote)
        }
            
            
//            .padding(.vertical, 12)
//            .padding(.horizontal, 16)
    }

}

extension StringProtocol {
    var double: Double? { Double(self) }
    var float: Float? { Float(self) }
    var integer: Int? { Int(self) }
}
