//
//  Path.swift
//  Run
//
//  Created by Jason Ho on 20/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import CocoaLumberjack
import SwiftyJSON

class Path: NSObject, NSCoding {
    let start: Int
    let end: Int
    let distance: Double
    
    init(json: JSON) {
        self.start = json["start"].intValue
        self.end = json["end"].intValue
        self.distance = json["distance"].doubleValue
        super.init()
    }
    
    // MARK: NSCoding
    required init(coder decoder: NSCoder) {
        self.start = decoder.decodeIntegerForKey("start")
        self.end = decoder.decodeIntegerForKey("end")
        self.distance = decoder.decodeDoubleForKey("distance")
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInt(Int32(self.start), forKey: "start")
        coder.encodeInt(Int32(self.end), forKey: "end")
        coder.encodeDouble(self.distance, forKey: "distance")
    }
}