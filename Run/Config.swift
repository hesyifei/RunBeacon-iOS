//
//  Config.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation

struct BasicConfig {
    static let CheckpointDataGetURL = "http://portal.ssc.edu.hk/schoolportal/index.php/Hi_score/get_setting_info"
    static let RunCheckPostURL = "http://portal.ssc.edu.hk/schoolportal/index.php/Hi_score/post_beacon"
    static let BeaconProximityUUID = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
    
    static let NavigationBarBackgroundColor = UIColor(red: 247.0/250.0, green: 247.0/250.0, blue: 247.0/250.0, alpha: 1.0)
    
    static let TripIDFromRecordView = "--NOT_A_TRIP--"
}


struct RunCellUIConfig {
    static let CellID = "RunningCell"
    static let TagIDs: [String: Int] = [               // 謹記不能為0（否則於cell.tag重複）或小於100（可能於其後cell.tag設置後重複）
        "leftView": 100,
        "timelineView": 110,
        "numberLabel": 120,
        "totalTimeLabel": 121,
        "rightView": 200,
        "timeCurrentLabel": 210,
        "timeReferenceLabel": 211,
        "speedCurrentLabel": 221,
    ]
    
    static let ViewWidths: [String: CGFloat] = [       // 固定寬度之view
        "numberLabel": 40.0,
        "timelineView": 15.0,
    ]
    static let ViewHeights: [String: CGFloat] = [       // 固定高度之view
        "totalTimeLabel": 20.0,
    ]
    
    static let TimelineRectConfig: [String: CGFloat] = [
        "Timeline Width": 5.0,
        "Circle Diameter": 15.0,                // 最好不要少於15.0
        "Top/Bottom Circle Padding": 5.0,
    ]
}