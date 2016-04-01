//
//  PracticeFrontViewController.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MapKit
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON
import MBProgressHUD
import Locksmith

class PracticeFrontViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // TODO: USE CLASS TO STORE/GET VALUE FOR EACH CHECKPOINT & TRIP
    // TODO: ADD TWO KINDS OF MODE 1. LIKE CURRENT 2. 橫向表格、顯示每次chekcpoint間的時間及標準時間
    // TODO: no need - USE UIIMAGEVIEW TO SHOW REDCROSS/WATER IN MKANNOTION ASSES VIEW
    // TODO: 【討論】通過json寫入每段距離/標準時間/標準速度etc
    
    
    // MARK: - IBOutlet var
    @IBOutlet var topMapView: RunMapView!
    @IBOutlet var startButton: UIButton!
    
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var locationManager: CLLocationManager!
    
    
    // MARK: - Data var
    var tripId = ""
    
    var checkpointsData = [Checkpoint]()
    
    var highlightedPoints = [               // For testing only
        CLLocationCoordinate2DMake(22.215606, 114.214801),
        CLLocationCoordinate2DMake(22.216758, 114.214811),
    ]
    
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Front View Controller 之 super.viewDidLoad() 已加載")
        
        
        let recordNavButton = UIBarButtonItem(title: "Record", style: .Plain, target: self, action: #selector(self.presentRecordView))
        self.navigationItem.leftBarButtonItems = [recordNavButton]
        
        let logoutNavButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(self.logoutAction))
        self.navigationItem.rightBarButtonItems = [logoutNavButton]
        
        
        
        
        
        topMapView.delegate = self
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        startButton.layer.cornerRadius = 25.0
        startButton.clipsToBounds = true
        startButton.setTitle("Ready", forState: .Normal)
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20.0)
        startButton.backgroundColor = UIColorConfig.GrassGreen
        startButton.addTarget(self, action: #selector(self.startButtonAction), forControlEvents: .TouchUpInside)
        
        
        initCheckpoints()
        
        
        if(CLLocationManager.authorizationStatus() != .AuthorizedAlways){
            DDLogError("定位服務未允許/未開啟，將提示用戶開啟後重啟App！")
            BasicFunc().showEnableLocationAlert(self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("Practice Front View Controller 之 super.viewWillAppear() 已加載")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Action func
    func startButtonAction() {
        self.tripId = NSUUID().UUIDString
        DDLogDebug("已生成此次tripId：\(tripId)")
        
        let practiceRunningVC = self.storyboard!.instantiateViewControllerWithIdentifier("PracticeRunningViewController") as! PracticeRunningViewController
        practiceRunningVC.tripId = self.tripId
        
        let navController = UINavigationController(rootViewController: practiceRunningVC)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func presentRecordView() {
        self.performSegueWithIdentifier("showPracticeRecordView", sender: self)
        DDLogDebug("準備進入PracticeRecordViewController")
    }
    
    func logoutAction() {
        let warningAlert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .Alert)
        warningAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            do {
                try Locksmith.deleteDataForUserAccount(BasicConfig.UserAccountID)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            } catch let error as NSError {
                DDLogError("無法刪除用戶登入數據：\(error)")
                BasicFunc().showErrorAlert(self, error: error)
            }
        }))
        warningAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        self.presentViewController(warningAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Data func
    func initCheckpoints() {
        checkpointsData = CheckpointFunc().getCheckpoints()
        topMapView.loadCheckpoints(checkpointsData)
    }
    
    
    // MARK: - MapView func
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return topMapView.funcRenderForOverlay(mapView, rendererForOverlay: overlay)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return topMapView.funcViewForAnnotation(mapView, viewForAnnotation: annotation, allCheckpoints: checkpointsData)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        topMapView.funcRegionDidChangeAnimated(mapView, regionDidChangeAnimated: animated)
    }
}