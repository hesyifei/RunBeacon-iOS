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
    
    func getCurrentVC() -> UIViewController {
        var rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        if let presentedVC = UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController {
            // 如果有一層presentedViewController
            rootVC = presentedVC
            if let presentedVCVC = presentedVC.presentedViewController {
                //（目前最多僅可以使用兩層presentedViewController、再多層需要繼續增加代碼）
                rootVC = presentedVCVC
            }
        }
        return rootVC!
    }
    
    
    func showAlert(selfVC: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        Async.main {
            selfVC.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorAlert(selfVC: UIViewController, error: NSError) {
        showAlert(selfVC, title: "Error", message: "\(error.localizedDescription)\n\n\(BasicConfig.ContactAdminMessage)")
    }
    
    
    
    func getAlertWithoutButton(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        // 將不會有按鈕出現（為阻止用戶繼續使用）
        return alert
    }
    
    func showEnableServicesAlert(selfVC: UIViewController, services: [String]) {
        let alertView = getAlertWithoutButton("Notice", message: "Please enable \(services.joinWithSeparator(", ")) in Settings.app and restart this application to continue.\n\n\(BasicConfig.ContactAdminMessage)")
        
        Async.main {
            selfVC.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    
    func doVibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}