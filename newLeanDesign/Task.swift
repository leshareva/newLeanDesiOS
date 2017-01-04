//
//  Task.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/11/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import DigitsKit

class Task: NSObject {
    var awareness: [String : String]?
    var concept: AnyObject?
    var design: AnyObject?
    var sources: AnyObject?
    var company: String?
    var fromId: String?
    var imageUrl: String?
    var phone: String?
    var price: NSNumber?
    var maxPrice: NSNumber?
    var minPrice: NSNumber?
    var messages: AnyObject?
    var rate: NSNumber?
    var status: String?
    var text: String?
    var taskId: String?
    var start: NSNumber?
    var end: NSNumber?
    var toId: String?
    var time: NSNumber?
    var timestamp: NSNumber?
    var unread: [String : AnyObject]?
    func chatPartnerId() -> String? {
        return fromId == Digits.sharedInstance().session()?.userID ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        awareness = dictionary["awareness"] as? [String : String]
        concept = dictionary["concept"] as AnyObject
        design = dictionary["design"] as AnyObject
        sources = dictionary["sources"] as AnyObject
        company = dictionary["company"] as? String
        fromId = dictionary["fromId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        phone = dictionary["phone"] as? String
        price = dictionary["price"] as? NSNumber
        maxPrice = dictionary["maxPrice"] as? NSNumber
        minPrice = dictionary["minPrice"] as? NSNumber
        rate = dictionary["rate"] as? NSNumber
        status = dictionary["status"] as? String
        text = dictionary["text"] as? String
        taskId = dictionary["taskId"] as? String
        start = dictionary["start"] as? NSNumber
        end = dictionary["end"] as? NSNumber
        toId = dictionary["toId"] as? String
        time = dictionary["time"] as? NSNumber
        timestamp = dictionary["timestamp"] as? NSNumber
        unread = dictionary["unread"] as? [String : AnyObject]
    }
    
}


