//
//  PracticeFrontViewController.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import CoreLocation
import Foundation
import MapKit
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON
import MBProgressHUD
import Locksmith
import KLCPopup

class PracticeFrontViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // TODO: 通過json寫入每段距離/標準時間/標準速度etc
    
    
    // MARK: - IBOutlet var
    @IBOutlet var topMapView: RunMapView!
    @IBOutlet var startButton: UIButton!
    
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var locationManager: CLLocationManager!
    
    var countdownTimer: NSTimer?
    var countdownInt: Int!
    
    var popupController: KLCPopup!
    var timerLabel: UILabel!
    
    var audioPlayer: AVAudioPlayer!
    
    
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
        
        
        self.title = "Practice"
        
        
        let recordNavButton = UIBarButtonItem(title: "Record", style: .Plain, target: self, action: #selector(self.presentRecordView))
        self.navigationItem.leftBarButtonItems = [recordNavButton]
        
        let logoutNavButton = UIBarButtonItem(title: "Logout", style: .Done, target: self, action: #selector(self.logoutAction))
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
        
        
        countdownInt = 3
        playSound("beep-low")
        BasicFunc().doVibration()
        
        Async.main {
            self.timerLabel = UILabel(frame: CGRectMake(0, 0, 180.0, 180.0))
            self.timerLabel.text = "\(self.countdownInt)"
            self.timerLabel.textAlignment = .Center
            self.timerLabel.font = UIFont(name: "AudimatMonoBold", size: 150.0)
            self.timerLabel.textColor = UIColor.blackColor()
            self.timerLabel.backgroundColor = UIColor.whiteColor()
            self.timerLabel.layer.cornerRadius = 5.0
            self.timerLabel.clipsToBounds = true
            
            self.popupController = KLCPopup(contentView: self.timerLabel)
            self.popupController.shouldDismissOnContentTouch = false
            self.popupController.shouldDismissOnBackgroundTouch = false
            self.popupController.maskType = .Dimmed
            self.popupController.showType = .GrowIn
            self.popupController.dismissType = .GrowOut
            
            self.popupController.willStartDismissingCompletion = {
                DDLogDebug("準備進入新跑步界面")
                let practiceRunningVC = self.storyboard!.instantiateViewControllerWithIdentifier("PracticeRunningViewController") as! PracticeRunningViewController
                practiceRunningVC.tripId = self.tripId
                
                let navController = UINavigationController(rootViewController: practiceRunningVC)
                self.presentViewController(navController, animated: true, completion: nil)
            }
            
            let layout = KLCPopupLayoutMake(.Center, .Center)
            self.popupController.showWithLayout(layout)
        }
        
        
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.calcCountdownTime), userInfo: nil, repeats: true)
        DDLogDebug("已開啟timer倒計計時器")
    }
    
    func calcCountdownTime() {
        countdownInt = countdownInt - 1
        DDLogVerbose("新countdownInt值：\(countdownInt)")
        self.timerLabel.text = "\(countdownInt)"
        
        BasicFunc().doVibration()
        
        if(countdownInt <= 0){
            playSound("gun")
            
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            self.popupController.dismiss(true)
        }else{
            playSound("beep-low")
        }
    }
    
    func playSound(soundName: String) {
        do {
            if let bundle = NSBundle.mainBundle().pathForResource(soundName, ofType: "wav") {
                DDLogDebug("準備播放音頻文件：\(soundName)")
                let alertSound = NSURL(fileURLWithPath: bundle)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)          // 設備靜音時將不會播放聲音
                try AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOfURL: alertSound)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
        } catch {
            DDLogError("無法播放音頻文件「\(soundName)」：\(error)")
        }
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