//
//  SaltyAlert.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/11/01.
//

import Foundation

struct SaltyAlert: Identifiable {
    
    enum AlertType {
        case deleteProject
        case error
        case confirm
    }
    
    let id: AlertType
    let title: String
    let message: String
    
}
