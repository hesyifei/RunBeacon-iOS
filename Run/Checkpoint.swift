//
//  Checkpoint.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import Async
import CocoaLumberjack
import SwiftyJSON

class Checkpoint: NSObject, NSCoding, MKAnnotation {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    
    init(json: JSON) {
        self.id = json["checkpointId"].intValue
        self.coordinate = CLLocationCoordinate2DMake(json["lat"].doubleValue, json["lng"].doubleValue)
        
        super.init()
    }
    
    
    // MARK: NSCoding
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeIntegerForKey("checkpointId")
        self.coordinate = CLLocationCoordinate2DMake(decoder.decodeDoubleForKey("lat"), decoder.decodeDoubleForKey("lng"))
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInt(Int32(self.id), forKey: "checkpointId")
        
        // 無法直接儲存座標（見 http://stackoverflow.com/a/14269810/2603230）
        coder.encodeDouble(self.coordinate.latitude, forKey: "lat")
        coder.encodeDouble(self.coordinate.longitude, forKey: "lng")
    }
}