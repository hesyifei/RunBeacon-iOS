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

enum CheckpointService {
    case Water
    case RedCross
}

class Checkpoint: NSObject, MKAnnotation {
    let id: Int
    let name: String
    let detail: String
    let services: [CheckpointService]
    let coordinate: CLLocationCoordinate2D
    
    init(id: Int, name: String, detail: String, services: [CheckpointService], coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.detail = detail
        self.services = services
        self.coordinate = coordinate
        
        super.init()
    }
}