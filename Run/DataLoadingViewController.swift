//
//  DataLoadingViewController.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON

class DataLoadingViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var locationManager: CLLocationManager!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Data Loading View Controller 之 super.viewDidLoad() 已加載")
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
        initCheckpointsData({
            Async.main {
                self.performSegueWithIdentifier("showPracticeView", sender: self)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Data func
    func initCheckpointsData(completion: () -> Void) {
        if(CheckpointFunc().getCheckpoints().count > 0){
            completion()
        }else{
            CheckpointFunc().loadCheckpointsDataFromServer({
                completion()
            })
        }
    }
}