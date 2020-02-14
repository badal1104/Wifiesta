//
//  CommonUtility.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 28/01/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import Foundation
import UIKit

class CommonUtility {
    
    // Common method to show alert
    class func showAlertMessage(messageString: String, controller: UIViewController, showSettingOption: Bool? = false)  {
        DispatchQueue.main.async {
            let showAlert = UIAlertController.init(title: nil, message:messageString , preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            showAlert.addAction(okAction)
            if showSettingOption!{
                let settionOption = UIAlertAction(title: "Settings", style: .default) { (action) in
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
                        UIApplication.shared.canOpenURL(settingsURL)
                        else {
                            return
                    }
                    UIApplication.shared.open(settingsURL)
                }
                showAlert.addAction(settionOption)
            }
            controller.present(showAlert, animated: true, completion: nil)
        }
        
    }
}
