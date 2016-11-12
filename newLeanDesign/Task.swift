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
    var awareness: AnyObject?
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
    
    func chatPartnerId() -> String? {
        return fromId == Digits.sharedInstance().session()?.userID ? toId : fromId
    }
}


