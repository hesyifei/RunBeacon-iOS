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
import Charts

class PracticeRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet var
    @IBOutlet var tableView: UITableView!
    @IBOutlet var chartView: LineChartView!
    
    // MARK: - Data/Init var
    var recordData: [PracticeRecord]!
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Record View Controller 之 super.viewDidLoad() 已加載")
        
        self.title = "Record"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        initChart()
        
        
        
        
        recordData = [
            PracticeRecord(runChecks: [
                RunCheck(checkpointId: 6, time: NSDate().dateByAddingTimeInterval(-230)),
                RunCheck(checkpointId: 5, time: NSDate().dateByAddingTimeInterval(-260)),
                RunCheck(checkpointId: 4, time: NSDate().dateByAddingTimeInterval(-275)),
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
    
    
    // MARK: - ChartView func
    func initChart() {
        
        /*
         圖標註釋：
         X軸：檢查站ID
         Y軸：從當次開始練習到該檢查站的總時間
         故圖標數值將只會永遠向上、不會減少
         */
        
        
        
        chartView.noDataText = "No chart data available."
        chartView.descriptionText = "Use your fingers to zoom in or out!"
        chartView.pinchZoomEnabled = true           // 允許手指同時放大XY兩軸
        chartView.animate(yAxisDuration: 1.0)       // 從下往上動態載入圖表
        
        
        let rightAxis = chartView.rightAxis         // 右側Y軸
        rightAxis.drawLabelsEnabled = false         // 不顯示右側Y軸
        rightAxis.drawGridLinesEnabled = false
        
        
        let leftAxis = chartView.leftAxis           // 左側Y軸
        leftAxis.drawAxisLineEnabled = true         // 顯示軸
        leftAxis.drawGridLinesEnabled = false       // 不於圖表內顯示橫軸線
        let leftAxisFormatter = NSNumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 0
        leftAxis.valueFormatter = leftAxisFormatter // 左側Y軸值valueFormatter
        
        
        let xAxis = chartView.xAxis                 // X軸
        xAxis.drawAxisLineEnabled = true            // 顯示軸
        xAxis.drawGridLinesEnabled = false          // 不於圖表內顯示縱軸線
        xAxis.labelPosition = .Bottom
        xAxis.setLabelsToSkip(0)                    // X軸不隱藏任何值（見文檔）
        
        
        
        
        //let months = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        let userAverageTime: [Double] = CheckpointFunc().getCheckpoints().map{ (eachCheckpoint) -> Double in
            return Double(eachCheckpoint.id*((2)^eachCheckpoint.id))
        }
        
        let userAverageTimeDataSet = LineChartDataSet(yVals: getChartDataEntry(userAverageTime), label: "Your Average")
        //userAverageTimeDataSet.circleColors = [UIColor.blackColor()]
        userAverageTimeDataSet.colors = [UIColorConfig.DarkRed]
        userAverageTimeDataSet.fillColor = UIColorConfig.DarkRed
        userAverageTimeDataSet.drawCirclesEnabled = false
        userAverageTimeDataSet.drawCubicEnabled = true
        userAverageTimeDataSet.drawFilledEnabled = true
        
        
        
        // 設定X軸底部內容
        let checkpointsName: [String] = CheckpointFunc().getCheckpoints().map{ (eachCheckpoint) -> String in
            return "\(eachCheckpoint.id)"
        }
        let lineChartData = LineChartData(xVals: checkpointsName, dataSets: [userAverageTimeDataSet])
        chartView.data = lineChartData
    }
    
    func getChartDataEntry(values: [Double]) -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []
        for (index, value) in values.enumerate() {
            let dataEntry = ChartDataEntry(value: value, xIndex: index)
            dataEntries.append(dataEntry)
        }
        return dataEntries
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