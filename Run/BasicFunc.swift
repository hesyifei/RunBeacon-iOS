//
//  BasicFunc.swift
//  Run
//
//  Created by Jason Ho on 31/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import CocoaLumberjack

class BasicFunc {
    func showAlert(selfVC: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        selfVC.presentViewController(alert, animated: true, completion: nil)
    }
}