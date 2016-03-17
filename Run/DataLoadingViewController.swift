//
//  DataLoadingViewController.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import Alamofire
import CocoaLumberjack

class DataLoadingViewController: UIViewController {
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Data Loading View Controller 之 super.viewDidLoad() 已加載")
        
        initCheckpointsData({
            Async.main {
                //self.performSegueWithIdentifier("showLoginView", sender: self)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Data func
    func initCheckpointsData(completion: () -> Void) {
        CheckpointFunc().loadCheckpointsDataFromServer({
            completion()
        })
    }
}