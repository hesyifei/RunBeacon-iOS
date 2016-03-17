//
//  RunCheck.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import CocoaLumberjack

class RunCheck: NSObject {
    let checkpointId: Int
    let time: NSDate
    
    init(checkpointId: Int, time: NSDate){
        self.checkpointId = checkpointId
        self.time = time
        super.init()
    }
}