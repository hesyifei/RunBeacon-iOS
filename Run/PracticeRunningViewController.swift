//
//  PracticeRunningViewController.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import AudioToolbox
import CoreLocation
import Foundation
import MapKit
import Async
import CocoaLumberjack
import KLCPopup

class PracticeRunningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topMapView: RunMapView!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var bottomBar: UIView!
    @IBOutlet var bottomLabel: UILabel!
    
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var locationManager: CLLocationManager!
    
    
    // MARK: UI var
    var popupController: KLCPopup = KLCPopup()
    
    let navigationColor = UIColor(red: 247.0/250.0, green: 247.0/250.0, blue: 247.0/250.0, alpha: 1.0)
    
    
    // MARK: - Data/Init var
    var runChecks = [RunCheck]()
    var checkpointsData = [Checkpoint]()
    
    var timer: NSTimer?
    var timerCount = 0
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Running View Controller 之 super.viewDidLoad() 已加載")
        
        
        runChecks = [
            RunCheck(checkpointId: 2, time: NSDate()),
            RunCheck(checkpointId: 1, time: NSDate().dateByAddingTimeInterval(-60)),
            RunCheck(checkpointId: 3, time: NSDate().dateByAddingTimeInterval(-120)),
            RunCheck(checkpointId: 2, time: NSDate().dateByAddingTimeInterval(-180)),
            RunCheck(checkpointId: 1, time: NSDate().dateByAddingTimeInterval(-200)),
            RunCheck(checkpointId: 0, time: NSDate().dateByAddingTimeInterval(-210)),
        ]
        
        
        
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        doVibration()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .None
        
        
        topMapView.delegate = self
        
        
        
        let closeNavButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "closeView")
        self.navigationItem.leftBarButtonItems = [closeNavButton]
        
        
        timeLabel.textColor = UIColor.blackColor()
        timeLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        timeLabel.font = UIFont(name: "AudimatMonoBold", size: 80.0)
        
        
        bottomBar.backgroundColor = navigationColor
        
        let bottomBarTopBorder = CALayer()
        bottomBarTopBorder.frame = CGRectMake(0, 0, bottomBar.frame.size.width, 1.0)
        bottomBarTopBorder.backgroundColor = UIColor.blackColor().CGColor
        bottomBar.layer.addSublayer(bottomBarTopBorder)
        
        
        initCheckpoints()
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "countTime", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        DDLogInfo("Practice Running View Controller 之 super.viewDidAppear() 已加載")
        
        
        /*timesCurrent = ["05:05"] + timesCurrent
        timesGood = ["02:03"] + timesGood
        speedsCurrent = ["3 m/s"] + speedsCurrent
        speedsGood = ["10 m/s"] + speedsGood
        totalTime = ["08:30"] + totalTime
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
        tableView.endUpdates()*/
        
        //showPopupWithStyle()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        DDLogInfo("Practice Running View Controller 之 super.viewDidDisappear() 已加載")
        
        timer!.invalidate()
        timer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - LocationManager func
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last
        let speed = loc?.speed
        DDLogVerbose("已獲取用戶目前速度：\(speed)")
        bottomLabel.text = "YA \(speed)"
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
        if status == .Denied || status == .Restricted {
            DDLogWarn("定位服務未允許/未開啟，無法檢測iBeacon！")
        }
    }
    
    var currentBeacon = [String]()
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {
            // 這裡可能會產生bug（直接提取[0]似乎有問題）
            let beacon = beacons[0]
            if(currentBeacon == [beacon.proximityUUID.UUIDString, beacon.major.stringValue, beacon.minor.stringValue]){
                DDLogVerbose("繼續維持在Beacon（\(beacon.major), \(beacon.minor), \(beacon.proximity.rawValue)）的範圍內")
            }else{
                DDLogInfo("已進入新Beacon（\(beacon.major), \(beacon.minor), \(beacon.proximity.rawValue)）範圍")
                
                runChecks = [RunCheck(checkpointId: beacon.minor.integerValue, time: NSDate())] + runChecks
                
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                tableView.endUpdates()
                
                currentBeacon = [beacon.proximityUUID.UUIDString, beacon.major.stringValue, beacon.minor.stringValue]
            }
        } else {
            // 一個iBeacon都沒有
        }
    }
    
    func startScanning() {
        DDLogInfo("開始掃描iBeacon")
        
        // 所有iBeacon均應設置為這一UUID
        let uuid = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "CheckpointBeacon")
        
        beaconRegion.notifyEntryStateOnDisplay = true
        
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    
    // MARK: - Data func
    func initCheckpoints() {
        checkpointsData = CheckpointFunc().getCheckpoints()
        topMapView.loadCheckpoints(checkpointsData)
    }
    
    
    // MARK: - MapView func
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegueWithIdentifier("showCheckpointDetail", sender: self)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return topMapView.funcRenderForOverlay(mapView, rendererForOverlay: overlay)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return topMapView.funcViewForAnnotation(mapView, viewForAnnotation: annotation, highlightedPoints: [])
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        topMapView.funcRegionDidChangeAnimated(mapView, regionDidChangeAnimated: animated)
    }
    
    
    // MARK: - TableView func
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runChecks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /*** 初始化TableCell開始 ***/
        let cellID = "RunningCell"
        let tagIDs: [String: Int] = [               // 謹記不能為0（否則於cell.tag重複）或小於100（可能於其後cell.tag設置後重複）
            "leftView": 100,
            "timelineView": 110,
            "numberLabel": 120,
            "totalTimeLabel": 121,
            "rightView": 200,
            "timeCurrentLabel": 210,
            "timeBestLabel": 211,
            "speedCurrentLabel": 221,
            "speedBestLabel": 222,
        ]
        
        let viewWidths: [String: CGFloat] = [       // 固定寬度之view
            "numberLabel": 35.0,
            "timelineView": 15.0,
        ]
        
        
        var cell: UITableViewCell!
        
        
        var leftView: UIView!
        var timelineView: TimelineView!
        var numberLabel: UILabel!
        var totalTimeLabel: UILabel!
        
        var rightView: UIView!
        var timeCurrentLabel: PaddingLabel!
        var timeBestLabel: PaddingLabel!
        var speedCurrentLabel: PaddingLabel!
        var speedBestLabel: PaddingLabel!
        
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier(cellID) {
            cell = reuseCell
            
            
            leftView = cell?.contentView.viewWithTag(tagIDs["leftView"]!)
            numberLabel = cell?.contentView.viewWithTag(tagIDs["numberLabel"]!) as! UILabel
            totalTimeLabel = cell?.contentView.viewWithTag(tagIDs["totalTimeLabel"]!) as! UILabel
            
            rightView = cell?.contentView.viewWithTag(tagIDs["rightView"]!)
            timeBestLabel = cell?.contentView.viewWithTag(tagIDs["timeBestLabel"]!) as! PaddingLabel
            timeCurrentLabel = cell?.contentView.viewWithTag(tagIDs["timeCurrentLabel"]!) as! PaddingLabel
            speedCurrentLabel = cell?.contentView.viewWithTag(tagIDs["speedCurrentLabel"]!) as! PaddingLabel
            speedBestLabel = cell?.contentView.viewWithTag(tagIDs["speedBestLabel"]!) as! PaddingLabel
        } else {
            DDLogVerbose("目前Cell \(indexPath.row)為nil，即將創建新Cell")
            
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellID)
            
            
            /** leftView 開始（為使其供點擊） **/
            leftView = UIView()
            leftView.tag = tagIDs["leftView"]!
            leftView.backgroundColor = UIColor.clearColor()
            leftView.userInteractionEnabled = true
            leftView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.insertSubview(leftView, atIndex: 0)
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: leftView, attribute: .Leading, relatedBy: .Equal, toItem: cell.contentView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: leftView, attribute: .Top, relatedBy: .Equal, toItem: cell.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: leftView, attribute: .Bottom, relatedBy: .Equal, toItem: cell.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: leftView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: viewWidths["numberLabel"]!+viewWidths["timelineView"]!),            // 寬度=numberLabel+timelineView的寬度
                ])
            
            
            /** numberLabel 開始 **/
            numberLabel = UILabel()
            numberLabel.tag = tagIDs["numberLabel"]!
            numberLabel.textAlignment = .Center
            numberLabel.userInteractionEnabled = true
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            leftView.addSubview(numberLabel)
            
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: numberLabel, attribute: .Leading, relatedBy: .Equal, toItem: leftView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: numberLabel, attribute: .Top, relatedBy: .Equal, toItem: leftView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: numberLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: viewWidths["numberLabel"]!),          // 應為一個正方形，所以height=width
                NSLayoutConstraint(item: numberLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: viewWidths["numberLabel"]!),
                ])
            
            
            /** totalTimeLabel 開始 **/
            totalTimeLabel = UILabel()
            totalTimeLabel.tag = tagIDs["totalTimeLabel"]!
            totalTimeLabel.textAlignment = .Center
            totalTimeLabel.userInteractionEnabled = true
            totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
            leftView.addSubview(totalTimeLabel)
            
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: totalTimeLabel, attribute: .Leading, relatedBy: .Equal, toItem: leftView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: totalTimeLabel, attribute: .Top, relatedBy: .Equal, toItem: numberLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: totalTimeLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 20.0),
                NSLayoutConstraint(item: totalTimeLabel, attribute: .Width, relatedBy: .Equal, toItem: numberLabel, attribute: .Width, multiplier: 1.0, constant: 0.0),
                ])
            
            
            
            /** rightView 開始 **/
            rightView = UIView()
            rightView.tag = tagIDs["rightView"]!
            rightView.backgroundColor = UIColor.clearColor()
            rightView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.insertSubview(rightView, atIndex: 0)
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: rightView, attribute: .Leading, relatedBy: .Equal, toItem: leftView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: rightView, attribute: .Trailing, relatedBy: .Equal, toItem: cell.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: rightView, attribute: .Top, relatedBy: .Equal, toItem: cell.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: rightView, attribute: .Bottom, relatedBy: .Equal, toItem: cell.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                ])
            
            
            /** timeCurrentLabel 開始 **/
            timeCurrentLabel = PaddingLabel()
            timeCurrentLabel.tag = tagIDs["timeCurrentLabel"]!
            timeCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
            rightView.addSubview(timeCurrentLabel)
            
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: timeCurrentLabel, attribute: .Leading, relatedBy: .Equal, toItem: rightView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeCurrentLabel, attribute: .Top, relatedBy: .Equal, toItem: rightView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeCurrentLabel, attribute: .Height, relatedBy: .Equal, toItem: rightView, attribute: .Height, multiplier: 0.6, constant: 0.0),
                NSLayoutConstraint(item: timeCurrentLabel, attribute: .Width, relatedBy: .Equal, toItem: rightView, attribute: .Width, multiplier: 0.5, constant: 0.0),
                ])
            
            
            /** timeBestLabel 開始 **/
            timeBestLabel = PaddingLabel()
            timeBestLabel.tag = tagIDs["timeBestLabel"]!
            timeBestLabel.translatesAutoresizingMaskIntoConstraints = false
            rightView.addSubview(timeBestLabel)
            
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: timeBestLabel, attribute: .Leading, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeBestLabel, attribute: .Top, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeBestLabel, attribute: .Bottom, relatedBy: .Equal, toItem: rightView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeBestLabel, attribute: .Width, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Width, multiplier: 1.0, constant: 0.0),
                ])
            
            
            /** speedCurrentLabel 開始 **/
            speedCurrentLabel = PaddingLabel()
            speedCurrentLabel.tag = tagIDs["speedCurrentLabel"]!
            speedCurrentLabel.textAlignment = .Right
            speedCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
            rightView.addSubview(speedCurrentLabel)
            
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: speedCurrentLabel, attribute: .Leading, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: speedCurrentLabel, attribute: .Trailing, relatedBy: .Equal, toItem: rightView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: speedCurrentLabel, attribute: .Top, relatedBy: .Equal, toItem: cell.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: speedCurrentLabel, attribute: .Height, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Height, multiplier: 1.0, constant: 0.0),
                ])
            
            
            /** speedBestLabel 開始 **/
            speedBestLabel = PaddingLabel()
            speedBestLabel.tag = tagIDs["speedBestLabel"]!
            speedBestLabel.textAlignment = .Right
            speedBestLabel.translatesAutoresizingMaskIntoConstraints = false
            rightView.addSubview(speedBestLabel)
            
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: speedBestLabel, attribute: .Trailing, relatedBy: .Equal, toItem: speedCurrentLabel, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: speedBestLabel, attribute: .Top, relatedBy: .Equal, toItem: speedCurrentLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: speedBestLabel, attribute: .Bottom, relatedBy: .Equal, toItem: rightView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: speedBestLabel, attribute: .Width, relatedBy: .Equal, toItem: speedCurrentLabel, attribute: .Width, multiplier: 1.0, constant: 0.0),
                ])
            
            
            
            /*
            numberLabel.backgroundColor = UIColor.brownColor()
            totalTimeLabel.backgroundColor = UIColor.lightGrayColor()
            speedCurrentLabel.backgroundColor = UIColor.yellowColor()
            speedBestLabel.backgroundColor = UIColor.brownColor()
            timeCurrentLabel.backgroundColor = UIColor.purpleColor()
            timeBestLabel.backgroundColor = UIColor.orangeColor()
            */
        }
        
        
        // 如果目前已有timelineView就移除（為防止上下移動時發生錯誤）
        if let existTimelineView = cell?.contentView.viewWithTag(tagIDs["timelineView"]!) as? TimelineView {
            existTimelineView.removeFromSuperview()
        }
        
        timelineView = TimelineView()
        timelineView.tag = tagIDs["timelineView"]!
        timelineView.isTop = indexPath.row == 0
        timelineView.isBottom = indexPath.row == runChecks.count-1
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        leftView.addSubview(timelineView)
        
        cell.contentView.addConstraints([
            NSLayoutConstraint(item: timelineView, attribute: .Leading, relatedBy: .Equal, toItem: numberLabel, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: timelineView, attribute: .Top, relatedBy: .Equal, toItem: cell.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: timelineView, attribute: .Bottom, relatedBy: .Equal, toItem: cell.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: timelineView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: viewWidths["timelineView"]!),
            ])
        
        
        //timelineView.backgroundColor = UIColor.blueColor()
        //DDLogVerbose("DONE \(cell?.contentView.subviews)")
        /*** 初始化TableCell結束 ***/
         
         
         
         
         /*** 修改數據開始 ***/
        let row = indexPath.row
        
        cell.tag = runChecks[row].checkpointId           // 供timelineTap使用
        
        
        numberLabel.text = "#\(runChecks[row].checkpointId)"
        numberLabel.font = UIFont(name: (numberLabel.font?.fontName)!, size: 15.0)
        
        
        let totalTime = getRunCheckTimeDifference(row, comparingIndex: runChecks.count-1)
        totalTimeLabel.text = "\(secondsToFormattedTime(totalTime))"
        totalTimeLabel.font = UIFont(name: (totalTimeLabel.font?.fontName)!, size: 8.0)
        
        
        let timeDifference = getRunCheckTimeDifference(row, comparingIndex: row+1)
        timeCurrentLabel.text = "\(secondsToFormattedTime(timeDifference))"
        timeCurrentLabel.font = UIFont(name: (timeCurrentLabel.font?.fontName)!, size: 28.0)
        
        
        let speed = getSpeed(timeDifference, distance: 5.0)
        speedCurrentLabel.text = "\(speed) m/s"
        speedCurrentLabel.font = UIFont(name: (speedCurrentLabel.font?.fontName)!, size: 28.0)
        
        
        /*timeBestLabel.text = timesGood[row]
        timeBestLabel.textColor = UIColor.grayColor()
        
        
        
        speedBestLabel.text = speedsGood[row]
        speedBestLabel.textColor = UIColor.grayColor()*/
        
        let timelineTapGesture = UITapGestureRecognizer(target: self, action: "timelineTap:")
        leftView.addGestureRecognizer(timelineTapGesture)
        
        /*** 修改數據結束 ***/
        
        return cell
    }
    
    func getRunCheckTimeDifference(currentIndex: Int, comparingIndex: Int) -> NSTimeInterval {
        var totalTime: NSTimeInterval = 0
        if(currentIndex < (runChecks.count-1)){
            totalTime = runChecks[currentIndex].time.timeIntervalSinceDate(runChecks[comparingIndex].time)
        }
        return totalTime
    }
    
    
    // MARK: - General func
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doVibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func countTime() {
        timerCount += 1
        timeLabel.text = millisecondsToFormattedTime(Double(timerCount))
    }
    
    func timelineTap(sender: UITapGestureRecognizer) {
        let tapLocation = sender.locationInView(tableView)
        
        let indexPath = tableView.indexPathForRowAtPoint(tapLocation)
        DDLogDebug("用戶已點擊 Cell \(indexPath?.row) 的 timeline")
        
        let cell = tableView.cellForRowAtIndexPath(indexPath!)
        let tag = cell?.tag
        
        topMapView.selectAnnotation(topMapView.allAnnotations[tag!], animated: true)
    }
    
    func showPopup() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let customView = CheckpointPopupView(frame: CGRectMake(0, 0, screenSize.width*0.85, screenSize.height*0.5))
        customView.backgroundLabel.text = "12"
        customView.timeLabel.text = "02:02"
        customView.speedLabel.text = "5 m/s"
        customView.leftBottomLargeLabel.text = "01:50"
        customView.leftBottomSmallLabel.text = "Suggest Time"
        customView.rightBottomLargeLabel.text = "7 m/s"
        customView.rightBottomSmallLabel.text = "Suggest Speed"
        
        popupController = KLCPopup(contentView: customView)
        popupController.shouldDismissOnContentTouch = false
        popupController.shouldDismissOnBackgroundTouch = true
        popupController.maskType = .Dimmed
        popupController.showType = .SlideInFromBottom
        popupController.dismissType = .SlideOutToBottom
        
        let layout = KLCPopupLayoutMake(.Center, .BelowCenter)
        popupController.showWithLayout(layout, duration: 15.0)
    }
    
    func secondsToFormattedTime(inputSeconds: Double) -> String {
        let roundSeconds = round(inputSeconds)
        
        let minutes = Int(roundSeconds/60)
        let seconds = Int(roundSeconds%60)
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    func millisecondsToFormattedTime(inputMilliseconds: Double) -> String {
        let roundMilliseconds = round(inputMilliseconds)
        
        let minutes = Int((roundMilliseconds/100)/60)
        let seconds = Int((roundMilliseconds/100)%60)
        let milliseconds = Int(roundMilliseconds%100)
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds)).\(String(format: "%02d", milliseconds))"
    }
    
    func getSpeed(seconds: Double, distance: Double) -> Double {
        return round(seconds)/distance
    }
}