//
//  TimelineView.swift
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
class TimelineView: UIView {
    
    var isTop = false
    var isBottom = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        DDLogVerbose("準備 TimelineView drawRect: \(isTop), \(isBottom) \(rect.height)")
        
        
        // 記得同時修改PracticeRunningViewController內的numberLabel的top及height
        let rectConfig: [String: CGFloat] = [
            "Timeline Width": 5.0,
            "Circle Diameter": 15.0,
            "Top/Bottom Circle Padding": 5.0,
        ]
        
        
        let originX = rect.width/2-rectConfig["Timeline Width"]!/2
        var originY = rect.origin.y
        let width = rectConfig["Timeline Width"]!
        var height = rect.height
        
        var roundingCorners = UIRectCorner()
        
        if(isTop){
            originY = originY+rectConfig["Top/Bottom Circle Padding"]!+rectConfig["Circle Diameter"]!/2
            height = height-rectConfig["Top/Bottom Circle Padding"]!
            roundingCorners = roundingCorners.union(.TopLeft)
            roundingCorners = roundingCorners.union(.TopRight)
        }
        
        if(isBottom){
            height = rectConfig["Top/Bottom Circle Padding"]!+rectConfig["Circle Diameter"]!/2
            if(isTop){          // 如果只有一個cell的話timeline高度應為0
                height = 0
            }
            
            roundingCorners = roundingCorners.union(.BottomLeft)
            roundingCorners = roundingCorners.union(.BottomRight)
        }
        
        
        let lineRect = CGRectMake(originX, originY, width, height)
        
        let linePath = UIBezierPath(roundedRect: lineRect, byRoundingCorners: roundingCorners, cornerRadii: CGSizeMake(15.0, 15.0))
        UIColor.grayColor().setFill()
        linePath.fill()
        
        
        
        let circleOriginX = lineRect.origin.x - (rectConfig["Circle Diameter"]!-rectConfig["Timeline Width"]!)/2
        
        
        let circleRect = CGRectMake(circleOriginX, rectConfig["Top/Bottom Circle Padding"]!, rectConfig["Circle Diameter"]!, rectConfig["Circle Diameter"]!)
        let topCircle = CircleView(frame: circleRect)
        //topCircle.circleColor = UIColor.greenColor()
        self.addSubview(topCircle)
    }
}