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
    
    var number = -1
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
        // Drawing code
        
        DDLogVerbose("準備 TimelineView drawRect: No. \(number), \(isTop), \(isBottom) \(rect.height)")
        
        // TODO: USE CLASS TO STORE/GET VALUE FOR EACH CHECKPOINT & TRIP
        // TODO: ADD A BEAUTIFUL "START" BUTTON
        // TODO: NO NEED TO DO - ADD AN ARROW(UP/DOWN) TO SHOW THE SPEED/TIME COMPARING TO LAST TIME
        // TODO: ADD TWO KINDS OF MODE 1. LIKE CURRENT 2. 橫向表格、顯示每次chekcpoint間的時間及標準時間
        
        
        
        let rectConfig: [String: CGFloat] = [
            "Timeline Width": 5.0,
            "Circle Diameter": 15.0,
            "Top/Bottom Circle Padding": 10.0,
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
        UIColor.greenColor().setFill()
        linePath.fill()
        
        
        
        let circleOriginX = lineRect.origin.x - (rectConfig["Circle Diameter"]!-rectConfig["Timeline Width"]!)/2
        
        
        let circleRect = CGRectMake(circleOriginX, rectConfig["Top/Bottom Circle Padding"]!, rectConfig["Circle Diameter"]!, rectConfig["Circle Diameter"]!)
        let topCircle = CircleView(frame: circleRect)
        //topCircle.alpha = 0.5
        self.addSubview(topCircle)
    }
}