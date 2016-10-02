//
//  LocalMessage.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 10/1/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import RealmSwift

class LocalMessage: Object {
    dynamic var status: String = ""
    dynamic var name: String = ""
    dynamic var photoUrl: String = ""
    dynamic var taskId: String = ""
    dynamic var fromId: String = ""
    dynamic var text: String = ""
    dynamic var timestamp: NSNumber = 0
    dynamic var toId: String = ""
    dynamic var imageUrl: String = ""
    dynamic var imageWidth: NSNumber = 0
    dynamic var imageHeight: NSNumber = 0
    dynamic var awareness: String = ""
    dynamic var concept: String = ""
}


