//
//  BasicFunc.swift
//  Run
//
//  Created by Jason Ho on 31/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Foundation
import Async
import CocoaLumberjack

class BasicFunc {
    func showAlert(selfVC: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        selfVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(selfVC: UIViewController, error: NSError) {
        showAlert(selfVC, title: "Error", message: "\(error.localizedDescription)\n\n\(BasicConfig.ContactAdminMessage)")
    }
    
    func showEnableLocationAlert(selfVC: UIViewController) {
        let alert = UIAlertController(title: "Notice", message: "Please enable Location Services and restart this application to continue.\n\n\(BasicConfig.ContactAdminMessage)", preferredStyle: .Alert)
        // 將不會有按鈕出現（為阻止用戶繼續使用）
        selfVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func doVibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}