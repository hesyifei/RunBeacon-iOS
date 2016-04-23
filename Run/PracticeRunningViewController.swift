//
//  PracticeRunningViewController.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import CoreBluetooth
import CoreLocation
import Foundation
import MapKit
import Async
import Alamofire
import CocoaLumberjack
import CRToast
import KLCPopup
import Locksmith

class PracticeRunningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topMapView: RunMapView!
    @IBOutlet var timeLabel: UILabel!
    
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var locationManager: CLLocationManager!
    var bluetoothPeripheralManager: CBPeripheralManager?
    
    
    var beaconRegion: CLBeaconRegion!
    
    
    // MARK: UI var
    var popupController: KLCPopup = KLCPopup()
    
    
    
    // MARK: - Data/Init var
    var tripId: String?
    
    var runChecks = [RunCheck]()
    var checkpointsData = [Checkpoint]()
    var pathsDict = [Int: Double]()
    var checkpointsGroupData = [Int: [Int]]()
    
    
    var currentBeacon = [String]()
    
    var timer: NSTimer?
    var timerStartTime: NSTimeInterval!
    
    
    var isRecord: Bool!
    var practiceRecord: PracticeRecord?
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Running View Controller 之 super.viewDidLoad() 已加載")
        
        
        self.isRecord = self.tripId == BasicConfig.TripIDFromRecordView
        DDLogVerbose("已設置isRecord值為\(isRecord)")
        
        if(isRecord == true){
            DDLogDebug("此次是一次練習記錄")
            DDLogVerbose("已獲取practiceRecord值：\(practiceRecord)")
            self.runChecks = (practiceRecord?.runChecks)!
        }else{
            DDLogDebug("此次是一次新練習")
            // 如果RunCheck內checkpointId為1即說明該點為起點、將會於cellForRowAtIndexPath做特殊處理
            /*self.runChecks = [
                //RunCheck(checkpointId: 4, time: NSDate()),
                //RunCheck(checkpointId: 3, time: NSDate().dateByAddingTimeInterval(-60)),
                //RunCheck(checkpointId: 7, time: NSDate().dateByAddingTimeInterval(-100)),
                //RunCheck(checkpointId: 6, time: NSDate().dateByAddingTimeInterval(-230)),
                //RunCheck(checkpointId: 5, time: NSDate().dateByAddingTimeInterval(-260)),
                RunCheck(checkpointId: 4, time: NSDate().dateByAddingTimeInterval(-320)),
                RunCheck(checkpointId: 3, time: NSDate().dateByAddingTimeInterval(-380)),
                RunCheck(checkpointId: 7, time: NSDate().dateByAddingTimeInterval(-400)),
                RunCheck(checkpointId: 6, time: NSDate().dateByAddingTimeInterval(-430)),
                RunCheck(checkpointId: 5, time: NSDate().dateByAddingTimeInterval(-460)),
                RunCheck(checkpointId: 4, time: NSDate().dateByAddingTimeInterval(-520)),
                RunCheck(checkpointId: 3, time: NSDate().dateByAddingTimeInterval(-580)),
                RunCheck(checkpointId: 2, time: NSDate().dateByAddingTimeInterval(-600)),
                RunCheck(checkpointId: 1, time: NSDate().dateByAddingTimeInterval(-610)),
            ]*/
            self.runChecks = [
                RunCheck(checkpointId: 1, time: NSDate()),
            ]
        }
        
        
        
        
        
        
        
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        topMapView.delegate = self
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        
        
        
        
        
        timeLabel.text = "\(secondsToFormattedTime(0))"
        timeLabel.font = UIFont(name: "AudimatMonoBold", size: 95.0)
        timeLabel.textColor = UIColor.blackColor()
        timeLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        
        
        // 所有iBeacon均應設置為同一UUID
        beaconRegion = CLBeaconRegion(proximityUUID: BasicConfig.BeaconProximityUUID!, identifier: "CheckpointBeacon")
        beaconRegion.notifyEntryStateOnDisplay = true
        
        
        if(isRecord == false){
            let cancelNavButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(self.cancelPractice))
            self.navigationItem.leftBarButtonItems = [cancelNavButton]
            
            //timerStartTime = NSDate.timeIntervalSinceReferenceDate()
            timerStartTime = runChecks[runChecks.count-1].time.timeIntervalSinceReferenceDate       // 使用第一個runCheck數據來當開始時間
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.calcTime), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
            DDLogDebug("已開啟timer計時器")
        }else{
            timeLabel.text = "\(secondsToFormattedTime((practiceRecord?.timeInterval)!))"
        }
        
        
        initCheckpoints()
    }
    
    // TODO: show alert if user dont have internet connection
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("Practice Running View Controller 之 super.viewWillAppear() 已加載")
        
        if(isRecord == false){
            // 防止用戶於跑步時自動鎖屏
            UIApplication.sharedApplication().idleTimerDisabled = true
            
            
            // 如果用戶允許永遠獲取位置就開始掃描iBeacon
            if(CLLocationManager.authorizationStatus() == .AuthorizedAlways){
                if(CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self)){
                    if(CLLocationManager.isRangingAvailable()){
                        startScanning()
                    }
                }
            }
            
            
            // 參見：http://stackoverflow.com/a/31449624/2603230
            let options = [CBCentralManagerOptionShowPowerAlertKey: 0]
            bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: options)
            bluetoothPeripheralManager?.delegate = self
            
        }
        
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
        
        
        if(isRecord == false){
            // 解除阻止自動鎖屏的限制
            UIApplication.sharedApplication().idleTimerDisabled = false
            
            
            timer!.invalidate()
            timer = nil
            DDLogInfo("已停止timer計時器")
            
            
            stopScanning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Core Bluetooth func
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
            let alert = UIAlertController(title: "Notice", message: "Please enable Bluetooth to continue.\n\n\(BasicConfig.ContactAdminMessage)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { action in
                Async.main(after: 3.0) {
                    // 在一定時間後再次檢測是否已開啟藍牙
                    self.peripheralManagerDidUpdateState(self.bluetoothPeripheralManager!)
                }
            }))
            Async.main {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - LocationManager func
    func startScanning() {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        DDLogInfo("開始掃描iBeacon")
    }
    
    func stopScanning() {
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
        DDLogInfo("停止掃描iBeacon")
    }
    
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let filteredBeacon = beacons.filter() { $0.proximity != .Unknown }      // 獲取所有距離非Unknown的Beacon
        
        if filteredBeacon.count > 0 {
            let beacon = filteredBeacon.first!          // 獲取距離最近的Beacon
            if(currentBeacon == [beacon.proximityUUID.UUIDString, beacon.major.stringValue, beacon.minor.stringValue]){
                DDLogVerbose("繼續維持在Beacon（\(beacon.major), \(beacon.minor), \(beacon.proximity.rawValue)）的範圍內")
            }else{
                DDLogInfo("已進入新Beacon（\(beacon.major), \(beacon.minor), \(beacon.proximity.rawValue)）範圍")
                
                
                
                let newRunCheck = RunCheck(checkpointId: beacon.minor.integerValue, time: NSDate())
                
                // TODO: 暫時無法判斷用戶是否往回跑、暫時擱置
                /*DDLogError("NEW ID: \(CheckpointFunc().getUploadCheckpointId(newRunCheck, runChecks: [newRunCheck] + runChecks))\nLATEST REAL ID: \(CheckpointFunc().getUploadCheckpointId(runChecks[runChecks.count-1], runChecks: runChecks))")*/
                
                
                runChecks = [newRunCheck] + runChecks
                
                
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                tableView.endUpdates()
                
                BasicFunc().doVibration()
                uploadRunCheckData(runChecks[0])
                
                if(CheckpointFunc().getUploadCheckpointId(newRunCheck, runChecks: runChecks) == checkpointsData[checkpointsData.count-1].id){
                    DDLogInfo("用戶已到達最後一個Checkpoint、即將結束跑步及計時")
                    finishPractice()
                    readSpeech(runChecks[0], isEnd: true)
                }else{
                    showCheckpointPopup()
                    readSpeech(runChecks[0])
                }
                
                currentBeacon = [beacon.proximityUUID.UUIDString, beacon.major.stringValue, beacon.minor.stringValue]
            }
        } else {
            // 一個iBeacon都沒有
        }
    }
    
    
    // MARK: - Data func
    func initCheckpoints() {
        checkpointsData = CheckpointFunc().getCheckpoints()
        topMapView.loadCheckpoints(checkpointsData)
        
        
        let pathsData = CheckpointFunc().getPaths()
        // pathsDict數據儲存規則是從pathsData中首個檢查站的ID一直到第key個檢查站的ID的總距離
        // 例如：pathsDict[5] = 從首個檢查站（有可能並非是pathsDict[1]因為首個檢查站ID取決於pathsData[0].start）到第5個檢查站的總距離
        // 注意在這裡pathsData必需要按上升順序儲存path數據、否則會出現嚴重錯誤
        pathsDict[pathsData[0].start] = 0.0             // pathsData[0].start即首個檢查站的ID
        for eachPath in pathsData{
            // 目前檢查站至首個檢查站的總距離 = 前一個檢查站至首個檢查站的總距離+前一個檢查站至目前檢查站的距離
            pathsDict[eachPath.end] = pathsDict[eachPath.start]!+eachPath.distance
        }
        DDLogVerbose("已完成整理pathsDict數據：\(pathsDict)")
        
        
        checkpointsGroupData = CheckpointFunc().getCheckpointsGroup()
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
    
    
    // MARK: - TableView func
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == runChecks.count-1){
            // 如果是最後一行、則不需要普通高度
            return RunCellUIConfig.TimelineRectConfig["Top/Bottom Circle Padding"]!+RunCellUIConfig.TimelineRectConfig["Circle Diameter"]!+RunCellUIConfig.ViewHeights["totalTimeLabel"]!
        }else{
            return 85.0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runChecks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /*** 初始化TableCell開始 ***/
        
        let cellID = RunCellUIConfig.CellID
        let tagIDs = RunCellUIConfig.TagIDs
        let viewWidths = RunCellUIConfig.ViewWidths
        let viewHeights = RunCellUIConfig.ViewHeights
        
        
        var cell: UITableViewCell!
        
        var leftView: UIView!
        var timelineView: TimelineView!
        var numberLabel: UILabel!
        var totalTimeLabel: UILabel!
        
        var rightView: UIView!
        var timeCurrentLabel: PaddingLabel!
        var timeReferenceLabel: PaddingLabel!
        var speedCurrentLabel: PaddingLabel!
        
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier(cellID) {
            cell = reuseCell
            
            
            leftView = cell?.contentView.viewWithTag(tagIDs["leftView"]!)
            numberLabel = cell?.contentView.viewWithTag(tagIDs["numberLabel"]!) as! UILabel
            totalTimeLabel = cell?.contentView.viewWithTag(tagIDs["totalTimeLabel"]!) as! UILabel
            
            rightView = cell?.contentView.viewWithTag(tagIDs["rightView"]!)
            timeReferenceLabel = cell?.contentView.viewWithTag(tagIDs["timeReferenceLabel"]!) as! PaddingLabel
            timeCurrentLabel = cell?.contentView.viewWithTag(tagIDs["timeCurrentLabel"]!) as! PaddingLabel
            speedCurrentLabel = cell?.contentView.viewWithTag(tagIDs["speedCurrentLabel"]!) as! PaddingLabel
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
                NSLayoutConstraint(item: numberLabel, attribute: .Top, relatedBy: .Equal, toItem: leftView, attribute: .Top, multiplier: 1.0, constant: RunCellUIConfig.TimelineRectConfig["Top/Bottom Circle Padding"]!),
                NSLayoutConstraint(item: numberLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: RunCellUIConfig.TimelineRectConfig["Circle Diameter"]!),
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
                NSLayoutConstraint(item: totalTimeLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: viewHeights["totalTimeLabel"]!),
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
                NSLayoutConstraint(item: rightView, attribute: .Top, relatedBy: .Equal, toItem: cell.contentView, attribute: .Top, multiplier: 1.0, constant: 25.0),
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
            
            
            /** timeReferenceLabel 開始 **/
            timeReferenceLabel = PaddingLabel()
            timeReferenceLabel.tag = tagIDs["timeReferenceLabel"]!
            timeReferenceLabel.translatesAutoresizingMaskIntoConstraints = false
            rightView.addSubview(timeReferenceLabel)
            
            cell.contentView.addConstraints([
                NSLayoutConstraint(item: timeReferenceLabel, attribute: .Leading, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeReferenceLabel, attribute: .Trailing, relatedBy: .Equal, toItem: rightView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeReferenceLabel, attribute: .Top, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: timeReferenceLabel, attribute: .Bottom, relatedBy: .Equal, toItem: rightView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
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
                NSLayoutConstraint(item: speedCurrentLabel, attribute: .Top, relatedBy: .Equal, toItem: rightView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: speedCurrentLabel, attribute: .Height, relatedBy: .Equal, toItem: timeCurrentLabel, attribute: .Height, multiplier: 1.0, constant: 0.0),
                ])
            
            
            
            /*
            numberLabel.backgroundColor = UIColor.brownColor()
            totalTimeLabel.backgroundColor = UIColor.lightGrayColor()
            timeCurrentLabel.backgroundColor = UIColor.purpleColor()
            timeReferenceLabel.backgroundColor = UIColor.orangeColor()
            speedCurrentLabel.backgroundColor = UIColor.yellowColor()
            */
            
        }
        
        
        let isTop = indexPath.row == 0
        let isBottom = indexPath.row == runChecks.count-1
        
        
        // 如果目前已有timelineView就移除（為防止上下移動時發生錯誤）
        if let existTimelineView = cell?.contentView.viewWithTag(tagIDs["timelineView"]!) as? TimelineView {
            existTimelineView.removeFromSuperview()
        }
        
        timelineView = TimelineView()
        timelineView.tag = tagIDs["timelineView"]!
        timelineView.isTop = isTop
        timelineView.isBottom = isBottom
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
        
        
        numberLabel.font = UIFont(name: (numberLabel.font?.fontName)!, size: 15.0)
        totalTimeLabel.font = UIFont(name: (totalTimeLabel.font?.fontName)!, size: 8.0)
        
        timeCurrentLabel.font = UIFont(name: (timeCurrentLabel.font?.fontName)!, size: 28.0)
        timeReferenceLabel.textColor = UIColor.grayColor()
        speedCurrentLabel.font = UIFont(name: (speedCurrentLabel.font?.fontName)!, size: 28.0)
        
        
        let totalTime = getRunCheckTimeDifference(row, comparingIndex: runChecks.count-1)
        totalTimeLabel.text = "\(secondsToFormattedTime(totalTime))"
        
        
        cell.tag = runChecks[row].checkpointId           // 供timelineAction使用
        
        let timelineTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.timelineAction(_:)))
        leftView.addGestureRecognizer(timelineTapGesture)
        
        if(!isBottom){
            numberLabel.text = "#\(runChecks[row].checkpointId)"
            
            let timeDifference = getRunCheckTimeDifference(row, comparingIndex: row+1)
            timeCurrentLabel.text = "\(secondsToFormattedTime(timeDifference))"
            
            timeReferenceLabel.text = "Ⓐ 02:00    Ⓣ 05:00"
            
            
            let startCheckpointId = CheckpointFunc().getUploadCheckpointId(runChecks[row+1], runChecks: runChecks)
            let endCheckpointId = CheckpointFunc().getUploadCheckpointId(runChecks[row], runChecks: runChecks)
            DDLogVerbose("準備獲取從\(startCheckpointId)到\(endCheckpointId)這段的距離")
            
            
            let distance = getDistance(start: startCheckpointId, end: endCheckpointId)
            if(distance != -1){
                DDLogVerbose("第\(row)行已獲取從\(startCheckpointId)到\(endCheckpointId)這段的距離：\(distance)")
                let speedText = getSpeedText(timeDifference, distance: distance)
                DDLogVerbose("第\(row)行已獲取從\(startCheckpointId)到\(endCheckpointId)這段的速度：\(speedText)")
                speedCurrentLabel.text = speedText
            }else{
                DDLogWarn("第\(row)行無法獲取從\(startCheckpointId)到\(endCheckpointId)這段的距離及速度")
                speedCurrentLabel.text = "Unknown"
            }
        }else{
            numberLabel.text = "Ⓑ"
            timeCurrentLabel.text = ""
            timeReferenceLabel.text = ""
            speedCurrentLabel.text = ""
        }
        
        /*** 修改數據結束 ***/
        
        return cell
    }
    
    
    // MARK: - General func
    func finishPractice() {
        closeView()
    }
    
    func cancelPractice() {
        let warningAlert = UIAlertController(title: "Warning", message: "This action is irreversible!\nAre you sure you want to cancel this practice?", preferredStyle: .Alert)
        warningAlert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
            self.closeView()
        }))
        warningAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        Async.main {
            self.presentViewController(warningAlert, animated: true, completion: nil)
        }
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func readSpeech(runCheck: RunCheck, isEnd: Bool = false) {
        Async.background {
            let totalTime = round(self.getRunCheckTimeDifference(0, comparingIndex: self.runChecks.count-1))
            let totalTimeString = "\(Int(totalTime/60)) minutes \(Int(totalTime%60)) seconds"
            
            var speechString = "Good job! You have just arrived Checkpoint \(runCheck.checkpointId). You have run for \(totalTimeString). Keep on running!"
            if(isEnd){
                speechString = "Congratulations! You have crossed the finish line! You have run for \(totalTimeString). Take a break now!"
            }
            
            DDLogDebug("即將讀出檢查站提示字句：\(speechString)")
            
            let speechsynt = AVSpeechSynthesizer()
            let speech = AVSpeechUtterance(string: speechString)
            speech.voice = AVSpeechSynthesisVoice(language: "en-GB")
            speech.rate = 0.45
            speechsynt.speakUtterance(speech)
        }
    }
    
    func calcTime() {
        let timeDifference = NSDate.timeIntervalSinceReferenceDate() - timerStartTime
        
        let minuteAndSecond = secondsToFormattedTime(timeDifference)
        timeLabel.text = "\(minuteAndSecond)"
    }
    
    func timelineAction(sender: UITapGestureRecognizer) {
        let tapLocation = sender.locationInView(tableView)
        
        let indexPath = tableView.indexPathForRowAtPoint(tapLocation)
        let cell = tableView.cellForRowAtIndexPath(indexPath!)
        let tag = cell?.tag
        
        DDLogDebug("用戶已點擊第\(indexPath?.row)行（tag \(tag)）的 timeline")
        
        if let annotationObject = topMapView.allAnnotationsDict[tag!] {
            topMapView.selectAnnotation(annotationObject, animated: true)
        }
    }
    
    func showCheckpointPopup() {
        var customView: CheckpointPopupView!
        Async.background {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            
            customView = CheckpointPopupView(frame: CGRectMake(0, 0, screenSize.width*0.85, screenSize.height*0.5))
            customView.backgroundLabel.text = "\(self.runChecks[0].checkpointId)"
            
            let timeDifference = self.getRunCheckTimeDifference(0, comparingIndex: 1)
            customView.timeLabel.text = "\(self.secondsToFormattedTime(timeDifference))"
            
            
            let startCheckpointId = CheckpointFunc().getUploadCheckpointId(self.runChecks[1], runChecks: self.runChecks)
            let endCheckpointId = CheckpointFunc().getUploadCheckpointId(self.runChecks[0], runChecks: self.runChecks)
            DDLogVerbose("彈窗準備獲取從\(startCheckpointId)到\(endCheckpointId)這段的距離")
            let distance = self.getDistance(start: startCheckpointId, end: endCheckpointId)
            if(distance != -1){
                DDLogVerbose("彈窗已獲取從\(startCheckpointId)到\(endCheckpointId)這段的距離：\(distance)")
                let speedText = self.getSpeedText(timeDifference, distance: distance)
                DDLogVerbose("彈窗已獲取從\(startCheckpointId)到\(endCheckpointId)這段的速度：\(speedText)")
                customView.speedLabel.text = speedText
            }else{
                DDLogWarn("彈窗無法獲取從\(startCheckpointId)到\(endCheckpointId)這段的距離及速度")
                customView.speedLabel.text = ""
            }
            
            
            // TODO: change speed & time to target/average here
            customView.leftBottomLargeLabel.text = "01:50"
            customView.leftBottomSmallLabel.text = "Suggest Time"
            customView.rightBottomLargeLabel.text = "7 m/s"
            customView.rightBottomSmallLabel.text = "Suggest Speed"
            }.main {
                self.popupController = KLCPopup(contentView: customView)
                self.popupController.shouldDismissOnContentTouch = false
                self.popupController.shouldDismissOnBackgroundTouch = true
                self.popupController.maskType = .Dimmed
                self.popupController.showType = .SlideInFromBottom
                self.popupController.dismissType = .SlideOutToBottom
                
                let layout = KLCPopupLayoutMake(.Center, .BelowCenter)
                self.popupController.showWithLayout(layout, duration: 15.0)
        }
    }
    
    func getDistance(start startCheckpointId: Int, end endCheckpointId: Int) -> Double {
        if let startDistance = pathsDict[startCheckpointId] {
            if let endDistance = pathsDict[endCheckpointId] {
                let totalDistance = endDistance-startDistance
                DDLogVerbose("已獲取從檢查站\(startCheckpointId)到\(endCheckpointId)的距離：\(totalDistance)")
                return totalDistance
            }
        }
        
        DDLogWarn("無法獲取從檢查站\(startCheckpointId)到\(endCheckpointId)的距離、即將return -1")
        return -1
    }
    
    func secondsToFormattedTime(inputSeconds: Double) -> String {
        let roundSeconds = round(inputSeconds)
        
        let minutes = Int(roundSeconds/60)
        let seconds = Int(roundSeconds%60)
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    func getSpeed(seconds: Double, distance: Double) -> Double {
        return round(seconds)/distance
    }
    func getSpeedText(seconds: Double, distance: Double) -> String {
        return String(format: "%.2f m/s", getSpeed(seconds, distance: distance))
    }
    
    func getRunCheckTimeDifference(currentIndex: Int, comparingIndex: Int) -> NSTimeInterval {
        var totalTime: NSTimeInterval = 0
        if(currentIndex < (runChecks.count-1)){
            totalTime = runChecks[currentIndex].time.timeIntervalSinceDate(runChecks[comparingIndex].time)
        }
        return totalTime
    }
    
    func uploadRunCheckData(runCheck: RunCheck) {
        
        let uploadId = CheckpointFunc().getUploadCheckpointId(runCheck, runChecks: runChecks)

        
        let userId = Locksmith.loadDataForUserAccount(BasicConfig.UserAccountID)!["username"] as! String
        
        let parameters = [
            "userId": userId,
            "tripId": "\(tripId!)",
            "checkpointId": "\(uploadId)",
        ]
        DDLogDebug("準備上傳RunCheck數據：\(parameters)")
        
        
        Alamofire.request(.POST, BasicConfig.RunCheckPostURL, parameters: parameters, encoding: .JSON)
            .response { request, response, data, error in
                if let error = error {
                    DDLogError("上傳RunCheck資訊失敗：\(error)")
                    CRToastManager.showNotificationWithMessage("Cannot upload checkpoint data to server!", completionBlock: nil)
                    BasicFunc().showErrorAlert(self, error: error)
                }else{
                    DDLogInfo("上傳RunCheck資訊成功")
                    CRToastManager.showNotificationWithMessage("Upload checkpoint data successfully!", completionBlock: nil)
                }
        }
    }
}