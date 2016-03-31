//
//  PracticeRecordViewController.swift
//  Run
//
//  Created by Jason Ho on 31/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import Alamofire
import CocoaLumberjack

class PracticeRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var recordData: [PracticeRecord]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Record View Controller 之 super.viewDidLoad() 已加載")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        recordData = [
            PracticeRecord(runChecks: [RunCheck(checkpointId: 6, time: NSDate().dateByAddingTimeInterval(-230)),
                RunCheck(checkpointId: 5, time: NSDate().dateByAddingTimeInterval(-260))]),
            PracticeRecord(runChecks: [
                RunCheck(checkpointId: 2, time: NSDate()),
                RunCheck(checkpointId: 1, time: NSDate().dateByAddingTimeInterval(-60)),
                RunCheck(checkpointId: 1, time: NSDate().dateByAddingTimeInterval(-160)),
                ]),
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return recordData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = "\(recordData[indexPath.row].timeInterval)"
        cell.detailTextLabel!.text = "\(recordData[indexPath.row].speed)"
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        DDLogInfo("用戶已點擊RecordCell")
        
        let practiceRunningVC = self.storyboard!.instantiateViewControllerWithIdentifier("PracticeRunningViewController") as! PracticeRunningViewController
        practiceRunningVC.tripId = BasicConfig.TripIDFromRecordView
        
        self.navigationController?.pushViewController(practiceRunningVC, animated: true)
    }
}

class PracticeRecord: NSObject {
    let runChecks: [RunCheck]
    
    
    let startTime: NSDate
    let endTime: NSDate
    
    let timeInterval: NSTimeInterval
    let speed: Int
    
    init(runChecks: [RunCheck]){
        self.runChecks = runChecks
        
        self.startTime = self.runChecks[self.runChecks.count-1].time
        self.endTime = self.runChecks[0].time
        
        self.timeInterval = self.endTime.timeIntervalSinceDate(self.startTime)
        self.speed = 5
        
        super.init()
    }
}