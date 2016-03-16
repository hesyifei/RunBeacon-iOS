//
//  CheckpointPopupView.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import CocoaLumberjack

class CheckpointPopupView: UIView {
    
    private let cornerRadius: CGFloat = 10.0
    
    
    
    var backgroundLabel: UILabel!
    
    
    private var topView: UIView!
    var timeLabel: UILabel!
    var speedLabel: UILabel!
    
    
    private var bottomView: UIView!
    
    private var leftBottomView: UIView!
    var leftBottomLargeLabel: UILabel!
    var leftBottomSmallLabel: UILabel!
    
    private var rightBottomView: UIView!
    var rightBottomLargeLabel: UILabel!
    var rightBottomSmallLabel: UILabel!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = cornerRadius
        
        
        backgroundLabel = UILabel()
        backgroundLabel.font = UIFont(name: "Topsquare", size: 270.0)
        backgroundLabel.textColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
        backgroundLabel.backgroundColor = UIColor.clearColor()
        backgroundLabel.textAlignment = .Center
        backgroundLabel.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(backgroundLabel, atIndex: 0)
        self.addConstraints([
            NSLayoutConstraint(item: backgroundLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            ])
        
        
        topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topView)
        self.addConstraints([
            NSLayoutConstraint(item: topView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: topView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: topView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: cornerRadius),
            NSLayoutConstraint(item: topView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.7, constant: 0.0),
            ])
        
        
        
        timeLabel = UILabel()
        timeLabel.font = UIFont(name: (timeLabel.font?.fontName)!, size: 80.0)
        timeLabel.textColor = UIColor.redColor()
        timeLabel.textAlignment = .Center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(timeLabel)
        
        topView.addConstraints([
            NSLayoutConstraint(item: timeLabel, attribute: .Leading, relatedBy: .Equal, toItem: topView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: timeLabel, attribute: .Trailing, relatedBy: .Equal, toItem: topView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: timeLabel, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: timeLabel, attribute: .Height, relatedBy: .Equal, toItem: topView, attribute: .Height, multiplier: 0.6, constant: 0.0),
            ])
        
        
        speedLabel = UILabel()
        speedLabel.font = UIFont(name: (speedLabel.font?.fontName)!, size: 40.0)
        speedLabel.textColor = UIColor.blueColor()
        speedLabel.textAlignment = .Center
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(speedLabel)
        
        topView.addConstraints([
            NSLayoutConstraint(item: speedLabel, attribute: .Leading, relatedBy: .Equal, toItem: topView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: speedLabel, attribute: .Trailing, relatedBy: .Equal, toItem: topView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: speedLabel, attribute: .Top, relatedBy: .Equal, toItem: timeLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: speedLabel, attribute: .Bottom, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            ])
        
        
        
        
        
        
        bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomView)
        self.addConstraints([
            NSLayoutConstraint(item: bottomView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomView, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -cornerRadius),
            ])
        
        
        
        
        leftBottomView = UIView()
        leftBottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(leftBottomView)
        
        bottomView.addConstraints([
            NSLayoutConstraint(item: leftBottomView, attribute: .Leading, relatedBy: .Equal, toItem: bottomView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomView, attribute: .Top, relatedBy: .Equal, toItem: bottomView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomView, attribute: .Width, relatedBy: .Equal, toItem: bottomView, attribute: .Width, multiplier: 0.5, constant: 0.0),
            ])
        
        
        
        leftBottomLargeLabel = UILabel()
        leftBottomLargeLabel.textAlignment = .Center
        leftBottomLargeLabel.font = UIFont(name: (leftBottomLargeLabel.font?.fontName)!, size: 30.0)
        leftBottomLargeLabel.translatesAutoresizingMaskIntoConstraints = false
        leftBottomView.addSubview(leftBottomLargeLabel)
        
        bottomView.addConstraints([
            NSLayoutConstraint(item: leftBottomLargeLabel, attribute: .Leading, relatedBy: .Equal, toItem: leftBottomView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomLargeLabel, attribute: .Trailing, relatedBy: .Equal, toItem: leftBottomView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomLargeLabel, attribute: .Top, relatedBy: .Equal, toItem: leftBottomView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomLargeLabel, attribute: .Height, relatedBy: .Equal, toItem: leftBottomView, attribute: .Height, multiplier: 0.6, constant: 0.0),
            ])
        
        
        leftBottomSmallLabel = UILabel()
        leftBottomSmallLabel.textAlignment = .Center
        leftBottomSmallLabel.textColor = UIColor.grayColor()
        leftBottomSmallLabel.translatesAutoresizingMaskIntoConstraints = false
        leftBottomView.addSubview(leftBottomSmallLabel)
        
        bottomView.addConstraints([
            NSLayoutConstraint(item: leftBottomSmallLabel, attribute: .Leading, relatedBy: .Equal, toItem: leftBottomView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomSmallLabel, attribute: .Trailing, relatedBy: .Equal, toItem: leftBottomView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomSmallLabel, attribute: .Top, relatedBy: .Equal, toItem: leftBottomLargeLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: leftBottomSmallLabel, attribute: .Bottom, relatedBy: .Equal, toItem: leftBottomView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            ])
        
        
        
        
        
        
        
        
        
        rightBottomView = UIView()
        rightBottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(rightBottomView)
        
        bottomView.addConstraints([
            NSLayoutConstraint(item: rightBottomView, attribute: .Leading, relatedBy: .Equal, toItem: leftBottomView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomView, attribute: .Trailing, relatedBy: .Equal, toItem: bottomView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomView, attribute: .Top, relatedBy: .Equal, toItem: bottomView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            ])
        
        
        
        rightBottomLargeLabel = UILabel()
        rightBottomLargeLabel.textAlignment = .Center
        rightBottomLargeLabel.font = UIFont(name: (rightBottomLargeLabel.font?.fontName)!, size: 30.0)
        rightBottomLargeLabel.translatesAutoresizingMaskIntoConstraints = false
        rightBottomView.addSubview(rightBottomLargeLabel)
        
        bottomView.addConstraints([
            NSLayoutConstraint(item: rightBottomLargeLabel, attribute: .Leading, relatedBy: .Equal, toItem: rightBottomView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomLargeLabel, attribute: .Trailing, relatedBy: .Equal, toItem: rightBottomView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomLargeLabel, attribute: .Top, relatedBy: .Equal, toItem: rightBottomView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomLargeLabel, attribute: .Height, relatedBy: .Equal, toItem: leftBottomLargeLabel, attribute: .Height, multiplier: 1.0, constant: 0.0),
            ])
        
        
        rightBottomSmallLabel = UILabel()
        rightBottomSmallLabel.textAlignment = .Center
        rightBottomSmallLabel.textColor = UIColor.grayColor()
        rightBottomSmallLabel.translatesAutoresizingMaskIntoConstraints = false
        rightBottomView.addSubview(rightBottomSmallLabel)
        
        bottomView.addConstraints([
            NSLayoutConstraint(item: rightBottomSmallLabel, attribute: .Leading, relatedBy: .Equal, toItem: rightBottomView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomSmallLabel, attribute: .Trailing, relatedBy: .Equal, toItem: rightBottomView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomSmallLabel, attribute: .Top, relatedBy: .Equal, toItem: rightBottomLargeLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightBottomSmallLabel, attribute: .Bottom, relatedBy: .Equal, toItem: rightBottomView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            ])
        
        
        
        /*
        // 為測試之用的背景
        topView.backgroundColor = UIColor.yellowColor()
        timeLabel.backgroundColor = UIColor.blueColor()
        speedLabel.backgroundColor = UIColor.purpleColor()
        bottomView.backgroundColor = UIColor.redColor()
        leftBottomView.backgroundColor = UIColor.greenColor()
        leftBottomLargeLabel.backgroundColor = UIColor.orangeColor()
        leftBottomSmallLabel.backgroundColor = UIColor.purpleColor()
        rightBottomView.backgroundColor = UIColor.blueColor()
        rightBottomLargeLabel.backgroundColor = UIColor.greenColor()
        rightBottomSmallLabel.backgroundColor = UIColor.whiteColor()
        */
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}