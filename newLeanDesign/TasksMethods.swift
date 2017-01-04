//
//  TasksMethods.swift
//  LeanDesign
//
//  Created by Sladkikh Alexey on 1/3/17.
//  Copyright © 2017 LeshaReva. All rights reserved.
//

import Alamofire
import Firebase

class TaskMethods {
    
    class func sendPush(message: String, toId: String, taskId: String? = nil ) {
        //send push notification
        let parameters: Parameters = [
            "userId": toId,
            "message": message,
            "taskId": taskId ?? "nil"
        ]
        
        Alamofire.request("\(Server.serverUrl)/push",
            method: .post,
            parameters: parameters).responseJSON { response in
                if let result = response.result.value as? [String: Any] {}
        }
    }

    
}



