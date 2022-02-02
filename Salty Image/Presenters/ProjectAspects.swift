//
//  ProjectAspects.swift
//  Salty Image
//
//  Created by Alireza Hajebrahimi on 2021/10/25.
//

import Foundation

// Project aspects
class ProjectAspects {
    
    // Variables
    var projectName: String?
    var totalScreenWidth: Double?
    var projectorDistance: Double?
    var imagesDimensions: [URL]?
    
    init() { }
    
    // Init function
    init(_ name: String, _ totalScreenWidth: Double, _ projectorDistance: Double, _ imageDimenstions: [URL]) {
        self.projectName        = name
        self.totalScreenWidth   = totalScreenWidth
        self.projectorDistance  = projectorDistance
        self.imagesDimensions   = imageDimenstions
    }
    
    // Return vars as dictionary [String: Any]
    var asDict : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
}

func urlsToNSItemProviders(urls: [URL]) -> [NSItemProvider] {
    var itemProviders: [NSItemProvider] = []
    for url in urls {
        itemProviders.append(NSItemProvider(contentsOf: url)!)
    }
    return itemProviders
}
