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

enum CheckpointService {
    case Water
    case RedCross
}

class Checkpoint: NSObject, MKAnnotation {
    let id: Int
    let name: String?
    let detail: String?
    //let services: [CheckpointService]?
    let coordinate: CLLocationCoordinate2D
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].string
        self.detail = json["detail"].string
        //self.services = json["services"].string
        self.coordinate = CLLocationCoordinate2DMake(json["latitude"].doubleValue, json["longitude"].doubleValue)
        
        super.init()
    }
}