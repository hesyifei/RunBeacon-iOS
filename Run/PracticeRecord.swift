//
//  PracticeRecord.swift
//  Run
//
//  Created by Jason Ho on 31/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

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