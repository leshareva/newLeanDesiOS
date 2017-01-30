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
    var `extension`: String?
    var imageUrl: String?
    var thumbnailLink: String?
    var name: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        timestamp = dictionary["timestamp"] as? NSNumber
        `extension` = dictionary["extension"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        name = dictionary["name"] as? String
        thumbnailLink = dictionary["thumbnailLink"] as? String
    }
    
}
