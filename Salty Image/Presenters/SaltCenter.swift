//
//  SaltCenter.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/27.
//

import Foundation

class SaltCenter {
    
    func saltCall(name: String) {
        NotificationCenter.default.post(name: Notification.Name(name), object: nil)
    }
    
    func saltPublisher(name: String) -> NotificationCenter.Publisher {
        return NotificationCenter.default.publisher(for: Notification.Name(name))
    }
}
