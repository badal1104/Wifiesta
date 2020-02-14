//
//  AnswerModel.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 10/02/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import Foundation

// MARK: -
// MARK: - AnswerModel
struct AnswerModel: Codable { // Bot response Model
    let Answers: [AnswerPayload]?
}
struct AnswerPayload: Codable {
    let Id, answer, messageType: String?
}
