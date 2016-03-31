//
//  LoginViewController.swift
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

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var loginButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Login View Controller 之 super.viewDidLoad() 已加載")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        loginButton.addTarget(self, action: #selector(self.loginButtonAction), forControlEvents: .TouchUpInside)
        
        
        /*
        /*** 僅供測試、實際將使用下方viewWillAppear的函數 ***/
        DDLogInfo("目前沒有Checkpoints相關數據儲存於本地、即將顯示下載View")
        self.performSegueWithIdentifier("showDataLoadingView", sender: self)
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("Login View Controller 之 super.viewWillAppear() 已加載")
        
        if(CheckpointFunc().getCheckpoints().count > 0){
            DDLogInfo("目前已有Checkpoints相關數據儲存於本地")
        }else{
            DDLogInfo("目前沒有Checkpoints相關數據儲存於本地、即將顯示下載View")
            self.performSegueWithIdentifier("showDataLoadingView", sender: self)
        }
    }
    
    func loginButtonAction() {
        self.performSegueWithIdentifier("showPracticeView", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}