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
    
    
    func loadCheckpointsDataFromServer(completion: () -> Void) {
        Alamofire.request(.GET, BasicConfig.CheckpointDataGetURL)
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
                    
                    CheckpointFunc().saveCheckpoints(checkpointsData)
                    
                    
                    self.defaults.setDouble(json["init"]["latitude"].doubleValue, forKey: "initLatitude")
                    self.defaults.setDouble(json["init"]["longitude"].doubleValue, forKey: "initLongitude")
                    self.defaults.setDouble(json["init"]["radius"].doubleValue, forKey: "initRadius")
                    DDLogVerbose("已從伺服器獲取init數據")
                    
                    
                    completion()
                }
        }
    }
    
}