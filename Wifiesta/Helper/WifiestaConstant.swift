//
//  WifiestaConstant.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 28/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import Foundation

enum ApiResponseCase { // Api response case to check its success or failure
      case success
      case failure
}

enum MediaContentType: String, CaseIterable{ // Media Content type for Itunes Media searcher
    case Music = "music"
    case TvShow = "tvShow"
    case Movie = "movie"
}

enum JsonFileCallType: String{ // Json file type to get User questions and Bot answer
    case questions = "WiBotQuestions"
    case answers = "WiBotAnswers"
}

enum UserType: Int{ // User type for identifying message owner
    case bot
    case human
}

enum MessageType: String { // Message type for identifying image or string.
    case defaultType = "0"
    case imageType = "1"
}

class WifiestaConstant {
    //API Url
    static let mediaSearcherUrlString = "https://itunes.apple.com/search?term=%@&media=%@"
  
    //Default Constant
    static let botIntroMessage = "Hey there friend! I am WiBot the chatbot. Ask me anything and I will try to answer."
    static let botdefaultAnswer = "Sorry, I'm still not sure about that."
    static let noDataFound = "No Results"
    static let emptySearchField = "Please enter text into searchbar"
    static let noInternetConnection = "Please check your network connection and try again."
    static let artistCellIdentifier = "cellIdentifier"
    static let playerControllerSegueIdentifier = "PlayerViewController"
    static let defaultAnswerID = "999"
    static let cameraPermission = "Camera access required for capturing photos"
    static let photoPermission = "Photo Library access required for uploading photos"
    static let messageTextViewMaxHeight = 90.0
    static let messageTextViewMinHeight = 34.0
    
    //Cell Identifiers
    static let wiUserImageCell = "wiUserImageCell"
    static let wiUserCell = "wiUserCell"
    static let wiBotCell = "wiBotCell"

}
