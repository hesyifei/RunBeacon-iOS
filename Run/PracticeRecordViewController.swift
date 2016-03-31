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
    
    // MARK: - IBOutlet var
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Data/Init var
    var recordData: [PracticeRecord]!
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Record View Controller 之 super.viewDidLoad() 已加載")
        
        self.title = "Record"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        recordData = [
            PracticeRecord(runChecks: [
                RunCheck(checkpointId: 6, time: NSDate().dateByAddingTimeInterval(-230)),
                RunCheck(checkpointId: 5, time: NSDate().dateByAddingTimeInterval(-260)),
                RunCheck(checkpointId: 1, time: NSDate().dateByAddingTimeInterval(-300)),
                ]),
            PracticeRecord(runChecks: [
                RunCheck(checkpointId: 3, time: NSDate()),
                RunCheck(checkpointId: 2, time: NSDate().dateByAddingTimeInterval(-60)),
                RunCheck(checkpointId: 1, time: NSDate().dateByAddingTimeInterval(-160)),
                ]),
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - TableView func
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return recordData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordCell", forIndexPath: indexPath) as UITableViewCell
        
        let currentRecord = recordData[indexPath.row]
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        cell.textLabel!.text = "\(dateFormatter.stringFromDate(currentRecord.startTime)) \(timeFormatter.stringFromDate(currentRecord.startTime))-\(timeFormatter.stringFromDate(currentRecord.endTime))"
        
        
        let durationString = PracticeRunningViewController().secondsToFormattedTime(currentRecord.timeInterval)
        
        cell.detailTextLabel!.text = "Ⓣ \(durationString)"
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        DDLogInfo("用戶已點擊RecordCell")
        
        let practiceRunningVC = self.storyboard!.instantiateViewControllerWithIdentifier("PracticeRunningViewController") as! PracticeRunningViewController
        practiceRunningVC.tripId = BasicConfig.TripIDFromRecordView
        practiceRunningVC.practiceRecord = recordData[indexPath.row]
        
        self.navigationController?.pushViewController(practiceRunningVC, animated: true)
    }
}