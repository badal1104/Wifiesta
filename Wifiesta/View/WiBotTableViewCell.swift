//
//  WiBotTableViewCell.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 02/02/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import UIKit

class WiBotTableViewCell: UITableViewCell {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var botMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       layoutWiBotCell()
    }
   
    private func layoutWiBotCell(){ // Set border to bot's message
        viewContainer.layer.cornerRadius = 5
        viewContainer.clipsToBounds = true
        viewContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
    }
    
    func loadBotCellData(messageModel: ChatModel) { // Load bot message to cell
        botMessageLabel.text = messageModel.message ?? ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
