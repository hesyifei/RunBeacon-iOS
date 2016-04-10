//
//  RaceViewController.swift
//  Run
//
//  Created by Jason Ho on 10/4/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON
import MBProgressHUD

class RaceViewController: UIViewController {
    
    // MARK: - IBOutlet var
    
    
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    
    
    // MARK: - Data var
    
    
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Race View Controller 之 super.viewDidLoad() 已加載")
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}