//
//  CheckpointFunc.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON

class CheckpointFunc {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let checkpointsDataKey = "checkpointsData"
    let pathsDataKey = "pathsData"
    let checkpointsGroupDataKey = "checkpointsGroupData"
    
    
    func saveCheckpoints(checkpoints: [Checkpoint]) {
        // 儲存checkpoints數據（參見：http://stackoverflow.com/a/26233274/2603230）
        let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(checkpoints)
        self.defaults.setObject(arrayOfObjectsData, forKey: checkpointsDataKey)
        
        DDLogDebug("已儲存checkpoints數據至defaults")
    }
    
    func getCheckpoints() -> [Checkpoint] {
        if let arrayOfObjectsUnarchivedData = defaults.dataForKey(checkpointsDataKey) {
            if let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as? [Checkpoint] {
                DDLogDebug("已從defaults獲取checkpoints數據")
                DDLogVerbose("checkpoints內容：\(arrayOfObjectsUnarchived)")
                
                return arrayOfObjectsUnarchived
            }
        }
        DDLogWarn("從defaults獲取checkpoints數據失敗、將返回空值")
        DDLogWarn("可能原因：第一次開啟App、checkpoints數據未設定")
        return []
    }
    
    
    func savePaths(paths: [Path]) {
        // 儲存paths數據（參見：http://stackoverflow.com/a/26233274/2603230）
        let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(paths)
        self.defaults.setObject(arrayOfObjectsData, forKey: pathsDataKey)
        
        DDLogDebug("已儲存paths數據至defaults")
    }
    
    func getPaths() -> [Path] {
        if let arrayOfObjectsUnarchivedData = defaults.dataForKey(pathsDataKey) {
            if let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as? [Path] {
                DDLogDebug("已從defaults獲取paths數據")
                DDLogVerbose("paths內容：\(arrayOfObjectsUnarchived)")
                
                return arrayOfObjectsUnarchived
            }
        }
        DDLogWarn("從defaults獲取paths數據失敗、將返回空值")
        DDLogWarn("可能原因：第一次開啟App、paths數據未設定")
        return []
    }
    
    
    
    func saveCheckpointsGroup(group: [Int: [Int]]) {
        let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(group)
        self.defaults.setObject(arrayOfObjectsData, forKey: checkpointsGroupDataKey)
        
        DDLogDebug("已儲存group數據至defaults")
    }
    func getCheckpointsGroup() -> [Int: [Int]] {
        if let arrayOfObjectsUnarchivedData = defaults.dataForKey(checkpointsGroupDataKey) {
            if let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as? [Int: [Int]] {
                DDLogDebug("已從defaults獲取group數據")
                DDLogVerbose("group內容：\(arrayOfObjectsUnarchived)")
                
                return arrayOfObjectsUnarchived
            }
        }
        DDLogWarn("從defaults獲取group數據失敗、將返回空值")
        DDLogWarn("可能原因：第一次開啟App、group數據未設定")
        return [0: []]
    }
    
    func getCheckpointsGroupMinAndMax() -> [String: Int] {
        
        let checkpointsGroupData = getCheckpointsGroup()
        
        // 這兩個將會代表繞圈時的最結束/最開始的兩點（這裡設定的是初始值）
        var smallestRepeatingCheckpointId = Int.max
        var biggestRepeatingCheckpointId = Int.min
        
        for (mainCheckpointId, _) in checkpointsGroupData {
            if(mainCheckpointId > biggestRepeatingCheckpointId){
                biggestRepeatingCheckpointId = mainCheckpointId
            }
            if(mainCheckpointId < smallestRepeatingCheckpointId){
                smallestRepeatingCheckpointId = mainCheckpointId
            }
        }
        return ["max": biggestRepeatingCheckpointId, "min": smallestRepeatingCheckpointId]
    }
    
    func getUploadCheckpointId(inputRunCheck: RunCheck, runChecks: [RunCheck]) -> Int {
        let checkpointsGroupData = CheckpointFunc().getCheckpointsGroup()
        
        
        // 將所有ID為inputRunCheck.checkpointId的runChecks提取出來並reverse以按時間正序排列
        var allRunCheckWithId = runChecks.filter{$0.checkpointId == inputRunCheck.checkpointId}
        allRunCheckWithId = allRunCheckWithId.reverse()
        
        
        // 默認情況（runCheck的ID不存在於checkpointsGroupData內）應直接上傳runCheck.checkpointId
        var returnInt = inputRunCheck.checkpointId
        
        if let targetIndex = allRunCheckWithId.indexOf({$0 == inputRunCheck}) {     // 看目前的inputRunCheck是第N個同樣的ID
            if let returnId = checkpointsGroupData[inputRunCheck.checkpointId]?[targetIndex] {         // 獲取應上傳ID
                returnInt = returnId
            }
        }
        DDLogDebug("已獲取此次（檢測到之原ID為\(inputRunCheck.checkpointId)）實際於伺服器上的checkpointId：\(returnInt)")
        return returnInt
    }
    
    
    
    func loadCheckpointsDataFromServer(completion: () -> Void) {
        Alamofire.request(.GET, BasicConfig.CheckpointDataGetURL)
            .response { request, response, data, error in
                if let error = error {
                    DDLogError("checkpoints伺服器數據獲取錯誤：\(error)")
                } else {
                    let json = JSON(data: data!)
                    var checkpointsData = [Checkpoint]()
                    
                    for (index, subJson): (String, JSON) in json["checkpoint"] {
                        let checkpointToBeAppend = Checkpoint(json: subJson)
                        checkpointsData.append(checkpointToBeAppend)
                        if(Int(index) == 0){
                            self.defaults.setDouble(checkpointToBeAppend.coordinate.latitude, forKey: "initLatitude")
                            self.defaults.setDouble(checkpointToBeAppend.coordinate.longitude, forKey: "initLongitude")
                            DDLogVerbose("已從通過第一個checkpoint設定init數據")
                        }
                    }
                    DDLogVerbose("已從伺服器獲取checkpointsData：\(checkpointsData)")
                    
                    CheckpointFunc().saveCheckpoints(checkpointsData)
                    
                    
                    
                    var pathsData = [Path]()
                    for (_, subJson): (String, JSON) in json["path"] {
                        let pathToBeAppend = Path(json: subJson)
                        pathsData.append(pathToBeAppend)
                    }
                    CheckpointFunc().savePaths(pathsData)
                    
                    
                    
                    var checkpointGroupData = [Int: [Int]]()
                    for (mainCheckpointId, subJson): (String, JSON) in json["group"] {
                        checkpointGroupData[Int(mainCheckpointId)!] = subJson.arrayValue.map{$0.intValue}
                    }
                    //DDLogWarn("GOOOOOOD \(checkpointGroupData)")
                    CheckpointFunc().saveCheckpointsGroup(checkpointGroupData)
                    
                    
                    completion()
                }
        }
    }
    
}