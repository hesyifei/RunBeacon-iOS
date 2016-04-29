//
//  PersonCheck.swift
//  Run
//
//  Created by Jason Ho on 29/4/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

class PersonCheck: NSObject {
    let personId: Int
    let time: NSDate
    
    init(personId: Int, time: NSDate){
        self.personId = personId
        self.time = time
        super.init()
    }
}