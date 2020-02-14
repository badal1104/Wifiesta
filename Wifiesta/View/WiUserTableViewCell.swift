//
//  WiUserTableViewCell.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 02/02/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import UIKit

class WiUserTableViewCell: UITableViewCell {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerHeight: NSLayoutConstraint?
    @IBOutlet weak var userMessageLabel: UILabel!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var userMessageImageView: UIImageView!
    @IBOutlet weak var userMessageLabelHeight: NSLayoutConstraint?
    var messageType: MessageType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCellLayout()
    }
    
    private func setCellLayout() { //Set border to user's messages
        if self.reuseIdentifier == WifiestaConstant.wiUserCell{
            viewContainer.layer.cornerRadius = 5
            viewContainer.clipsToBounds = true
            viewContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }else{
            imageViewContainer.layer.cornerRadius = 5
            imageViewContainer.clipsToBounds = true
            imageViewContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            
            userMessageImageView.layer.cornerRadius = 5
            userMessageImageView.clipsToBounds = true
            userMessageImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
    }
    
    func loadUserCellData(messageModel: ChatModel) { // Load user's messages to user cell
        if messageModel.messageType == MessageType.imageType.rawValue{
            if let imageBaseString = messageModel.message, !imageBaseString.isEmpty{
                if let dataDecoded = Data(base64Encoded: imageBaseString, options: NSData.Base64DecodingOptions(rawValue: 0)){
                    let image = UIImage(data: dataDecoded)
                    userMessageImageView.image = image!
                }else{
                    userMessageImageView.image = UIImage(named: "corruptImage") // Load default image when image is corrupt
                }
            }else{
                userMessageImageView.image = UIImage(named: "corruptImage")
            }
        }else{
            userMessageLabel.text = messageModel.message ?? ""
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
