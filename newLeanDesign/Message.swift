//
//  Message.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/17/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import DigitsKit

class Message: NSObject {
    var status: String?
    var name: String?
    var photoUrl: String?
    var taskId: String?
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var awareness: String?
    var concept: String?
    var design: String?
    var source: String?
    func chatPartnerId() -> String? {
        return fromId == Digits.sharedInstance().session()?.userID ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        status = dictionary["status"] as? String
        name = dictionary["name"] as? String
        photoUrl = dictionary["photoUrl"] as? String
        taskId = dictionary["taskId"] as? String
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        awareness = dictionary["awareness"] as? String
        concept = dictionary["concept"] as? String
    }
    
    
}

