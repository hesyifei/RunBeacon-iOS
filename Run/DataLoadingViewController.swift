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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Data Loading View Controller 之 super.viewDidLoad() 已加載")
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
        initCheckpointsData({
            self.performSegueWithIdentifier("showPracticeView", sender: self)
        })
    }
    
    
    func initCheckpointsData(completion: () -> Void) {
        if(DefaultsFunc().getCheckpoints().count > 0){
            completion()
        }else{
            Alamofire.request(.GET, "http://areflys-mac.local/checkpoints.json")
                .response { request, response, data, error in
                    if let error = error {
                        DDLogError("checkpoints伺服器數據獲取錯誤：\(error)")
                    } else {
                        let json = JSON(data: data!)
                        var checkpointsData = [Checkpoint]()
                        
                        for (_, subJson): (String, JSON) in json["checkpoints"] {
                            checkpointsData.append(Checkpoint(json: subJson))
                        }
                        DDLogVerbose("已從伺服器獲取checkpointsData：\(checkpointsData)")
                        
                        DefaultsFunc().saveCheckpoints(checkpointsData)
                        
                        completion()
                    }
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}