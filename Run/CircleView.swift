//
//  CircleView.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import CocoaLumberjack

@IBDesignable
class CircleView: UIView {
    var circleColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.circleColor = UIColor.blackColor()
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        let circleNew = UIBezierPath(ovalInRect: rect)
        circleColor.setFill()
        circleNew.fill()
    }
}