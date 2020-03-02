//
//  WiBotViewController.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 28/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class WiBotViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textfiledViewContainer: UIView!
    @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    var questionArray: [QuestionPayload]?
    var answerArray: [AnswerPayload]?
    var chatArray: [ChatModel] = [ChatModel(userType: .bot, message: WifiestaConstant.botIntroMessage)] // Set Bot intro message on load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextViewProperties()
        callAndLoadQuestionAnswerJson(withJsonFileType: .questions) // Call Json file to load User questions
        callAndLoadQuestionAnswerJson(withJsonFileType: .answers) // Call Json file to load Bot answer
        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotification()
    }
    
    func messageTextViewProperties() { // Set MessageTextView properties
        messageTextView.layer.cornerRadius = 5
        messageTextView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.masksToBounds = true
        messageTextView.enablesReturnKeyAutomatically = true
    }
    
    func addKeyboardNotification() { // Add Keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardNotification() { // Remove Keyboard notification
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func callAndLoadQuestionAnswerJson(withJsonFileType: JsonFileCallType) {
        if let url = Bundle.main.url(forResource: withJsonFileType.rawValue, withExtension: "json"){
            do{
                let jsonData = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                if withJsonFileType == .questions{ // Decode response into model as per the json file type
                    let model = try decoder.decode(QuestionModel.self, from:
                        jsonData) //Decode JSON Response Data
                    questionArray = model.Questions
                }else{
                    let model = try decoder.decode(AnswerModel.self, from:
                        jsonData) //Decode JSON Response Data
                    answerArray = model.Answers
                }
            }catch let parsingError{
                print("Error", parsingError)
            }
        }
        
    }
    
    @IBAction func openActionSheet(sender: UIButton){ // Create Action sheet to show camera and photo library options
        
        let optionMenu = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        let cameraOption = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCamera() // Call open camera
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.openGallery() // Call open gallery
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(cameraOption)
        optionMenu.addAction(photoLibrary)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func setImagePicker(with sourceType: UIImagePickerController.SourceType){ // Create imagePicker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func sendMessage(sender: UIButton){ // Send message to bot
        let charSet = CharacterSet.whitespacesAndNewlines
        if let trimmedString = messageTextView.text?.trimmingCharacters(in: charSet), !trimmedString.isEmpty{ // trimmed extra white space and new lines
            checkAndFilterQuestion(messageString: trimmedString) // filter question in questionModel
            messageTextView.text = ""
            resetMessageTextViewHeight() // reset message textView height
        }
    }
    
    func checkAndFilterQuestion(messageString: String) {
        let filterQuestionArray = questionArray?.filter{$0.question?.caseInsensitiveCompare(messageString) == .orderedSame}
        let messageModel = createChatModel(userType: .human, messageString: messageString)
        var matchQuestionId = ""
        if let matchfilteredQuestion = filterQuestionArray, !matchfilteredQuestion.isEmpty{ // filter answer from answer model by matching question ID with answer ID
            let matchQuestion = matchfilteredQuestion.last!
            matchQuestionId = matchQuestion.Id ?? ""
        }else{ // Set default bot response when no question matches
            matchQuestionId = WifiestaConstant.defaultAnswerID
        }
        createAndUpdateTableDataSource(messageModel: messageModel) // Add question into chatArray
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)  {
            self.filterBotAnser(Id: matchQuestionId)
        }
    }
    
    func createChatModel(userType: UserType, messageString: String, messageType: MessageType? = .defaultType)-> ChatModel { //Create chat model by using user and bot messages
        return ChatModel(userType: userType, message: messageString, messageType: messageType!)
    }
    
    func filterBotAnser(Id: String? = nil, messageType: String? = nil) { //Filter bot answer with messageType
        
        var filterAnswerArray: [AnswerPayload]?
        if let questionId = Id, !questionId.isEmpty{
            filterAnswerArray = answerArray?.filter{$0.Id == questionId}
        }else if let  messageTypeString = messageType, !messageTypeString.isEmpty{
            filterAnswerArray = answerArray?.filter{$0.messageType == messageTypeString}
        }
        if let matchfilteredAnswer = filterAnswerArray, !matchfilteredAnswer.isEmpty{
            let matchAnswer = matchfilteredAnswer.last!
            let messageModel = createChatModel(userType: .bot, messageString: matchAnswer.answer ?? WifiestaConstant.botdefaultAnswer)
            createAndUpdateTableDataSource(messageModel: messageModel)
        }
    }
    
    func createAndUpdateTableDataSource(messageModel: ChatModel) { // Update chatArray and relaod tableView
        chatArray.append(messageModel)
        self.chatTableView.reloadData()
        scrollChatTableViewToLatestMessage()
    }
    
    func scrollChatTableViewToLatestMessage() { // Scroll to current message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.chatArray.isEmpty{
                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatArray.count - 1, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) { // Update textViewContainer bottom constraint as per keyboard height
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        textViewContainerBottomConstraint.constant =  -keyboardFrame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.scrollChatTableViewToLatestMessage()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) { // Update textViewContainer bottom constraint as per keyboard height
        if let _ : NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            self.textViewContainerBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(gesture:)))
        tapGesture.cancelsTouchesInView = true
        tapGesture.numberOfTapsRequired = 1
        chatTableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard(gesture: UITapGestureRecognizer){
        messageTextView.resignFirstResponder()
    }
}

//MARK:-
//MARK:- UITableView Delegate & Datasource
extension WiBotViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableCell: UITableViewCell?
        let messageModel = chatArray[indexPath.row]
        if messageModel.userType == .human{ // Load cell as per the user type and message type
            let messageType =  MessageType(rawValue: messageModel.messageType!)
            if messageType == .imageType{
                let userImageCell = tableView.dequeueReusableCell(withIdentifier: WifiestaConstant.wiUserImageCell) as! WiUserTableViewCell
                userImageCell.loadUserCellData(messageModel: messageModel)
                tableCell = userImageCell
            }else{
                let userCell = tableView.dequeueReusableCell(withIdentifier: WifiestaConstant.wiUserCell) as! WiUserTableViewCell
                userCell.loadUserCellData(messageModel: messageModel)
                tableCell = userCell
            }
        }else{
            let wiBotCell = tableView.dequeueReusableCell(withIdentifier: WifiestaConstant.wiBotCell) as! WiBotTableViewCell
            wiBotCell.loadBotCellData(messageModel: messageModel)
            tableCell = wiBotCell
        }
        return tableCell!
    }
    
}

//MARK:-
//MARK:- UIImagePicker Delegate, Datasource & Methods
extension WiBotViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    func openCamera() { // Open camera and check camera permission
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            setImagePicker(with: .camera)
        case .denied:
            CommonUtility.showAlertMessage(messageString: WifiestaConstant.cameraPermission, controller: self, showSettingOption: true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setImagePicker(with: .camera)
                    }
                } else {
                    CommonUtility.showAlertMessage(messageString: WifiestaConstant.cameraPermission, controller: self, showSettingOption: true)
                }
            }
        case .restricted:
            CommonUtility.showAlertMessage(messageString: WifiestaConstant.cameraPermission, controller: self, showSettingOption: true)
        default:
            print("default")
        }
    }
    
    func openGallery() { // Open Photo library and check its permission
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            setImagePicker(with: .photoLibrary)
        }else if (status == PHAuthorizationStatus.denied) {
            CommonUtility.showAlertMessage(messageString: WifiestaConstant.photoPermission, controller: self, showSettingOption: true)
        }else if (status == PHAuthorizationStatus.notDetermined) {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    DispatchQueue.main.async {
                        self.setImagePicker(with: .photoLibrary)
                    }
                }
                else {
                    CommonUtility.showAlertMessage(messageString: WifiestaConstant.photoPermission, controller: self, showSettingOption: true)
                }
            })
        }else if (status == PHAuthorizationStatus.restricted) {
            CommonUtility.showAlertMessage(messageString: WifiestaConstant.photoPermission, controller: self, showSettingOption: true)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let pickedImage = info[.editedImage] as? UIImage { // Get edited image and convert it to base64String
            if let imageBase64String = pickedImage.jpegData(compressionQuality: 0.5)?.base64EncodedString(){
                let messageModel = createChatModel(userType: .human, messageString: imageBase64String, messageType: .imageType)
                createAndUpdateTableDataSource(messageModel: messageModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.filterBotAnser(messageType: MessageType.imageType.rawValue)
                }
            }
        }
    }
}

//MARK:-
//MARK:- UITextView Delegate & Methods
extension WiBotViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        increaseTextViewHeight(textView: textView) // Increase textview height
    }
    
    func increaseTextViewHeight(textView: UITextView) { // Increase textview height as per the text
        DispatchQueue.main.async {
            self.messageTextViewHeightConstraint.constant = CGFloat(min(WifiestaConstant.messageTextViewMaxHeight, max(WifiestaConstant.messageTextViewMinHeight, Double(textView.contentSize.height))))
            self.view.layoutIfNeeded()
        }
    }
    
    func resetMessageTextViewHeight() { //Reset textView height after sending message
        DispatchQueue.main.async {
            self.messageTextViewHeightConstraint.constant = CGFloat(min(WifiestaConstant.messageTextViewMaxHeight, WifiestaConstant.messageTextViewMinHeight))
            self.view.layoutIfNeeded()
        }
    }
}

//MARK:-
//MARK:- ScrollView Delegate
extension WiBotViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            messageTextView.resignFirstResponder()
        }
    }
}
