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
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        imgUrl = dictionary["imgUrl"] as? String
        text = dictionary["text"] as? String
    }
    
    
}

