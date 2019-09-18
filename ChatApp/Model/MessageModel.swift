//
//  MessageModel.swift
//  ChatApp
//
//  Created by Akshay Shedge on 17/09/19.
//  Copyright © 2019 Akshay Shedge. All rights reserved.
//

import Foundation

class MessageModel {
    var sender : String?
    var message : String?
    
    init(dict: [String:String]) {
        self.sender = dict["sender"]
        self.message = dict["message"]
    }
    
}
