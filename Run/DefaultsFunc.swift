//
//  DefaultsFunc.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import CocoaLumberjack

class DefaultsFunc {
    
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
        DDLogWarn("從defaults獲取checkpoints數據失敗、返回空值")
        DDLogWarn("可能原因：checkpoints數據未設定")
        return []
    }
}