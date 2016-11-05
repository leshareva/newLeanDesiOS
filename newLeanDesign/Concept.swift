//
//  Message.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/17/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit

class Concept: NSObject {
    
    var imgUrl: String?
    var text: String?
    var status: String?
    var deadline: NSNumber?
    var time: NSNumber?
    var price: NSNumber?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        imgUrl = dictionary["imgUrl"] as? String
        text = dictionary["text"] as? String
        price = dictionary["price"] as? NSNumber
        time = dictionary["time"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
    
}

