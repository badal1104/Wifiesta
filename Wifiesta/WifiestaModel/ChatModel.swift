//
//  ChatModel.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 10/02/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import Foundation

// MARK: -
// MARK: - ChatModel
struct ChatModel { // Chat Model of User and Bot
    let userType: UserType?
    let message: String?
    let messageType: String?
    init(userType: UserType, message: String, messageType: MessageType? = .defaultType) {
        self.userType = userType
        self.message = message
        self.messageType = messageType!.rawValue
    }
}
