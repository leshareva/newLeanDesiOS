//
//  Files.swift
//  Лин
//
//  Created by Sladkikh Alexey on 1/28/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import UIKit

class File: NSObject {
    var timestamp: NSNumber?
    var source: String?
    var thumbnailLink: String?
    var name: String?
    var width: String?
    var height: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        timestamp = dictionary["timestamp"] as? NSNumber
        source = dictionary["source"] as? String
        name = dictionary["name"] as? String
        thumbnailLink = dictionary["thumbnailLink"] as? String
        width = dictionary["width"] as? String
        height = dictionary["height"] as? String
    }
    
}
