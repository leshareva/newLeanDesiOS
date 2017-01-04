//
//  Source.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 12/30/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

//
//  Task.swift
//  leandesign
//
//  Created by Sladkikh Alexey on 8/11/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import DigitsKit

class Source: NSObject {
    var id: String?
    var name: String?
    var `extension`: String?
    var thumbnailLink: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        `extension` = dictionary["extension"] as? String
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        thumbnailLink = dictionary["thumbnailLink"] as? String
        }
    
}



