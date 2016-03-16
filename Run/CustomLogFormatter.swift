//
//  CustomLogFormatter.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import CocoaLumberjack

class CustomLogFormatter: NSObject, DDLogFormatter {
    func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        
        var prefixMessage = ""
        switch (logMessage.flag) {
        case DDLogFlag.Verbose:
            prefixMessage = "其它"
            break
        case DDLogFlag.Debug:
            prefixMessage = "記錄"
            break
        case DDLogFlag.Info:
            prefixMessage = "提示"
            break
        case DDLogFlag.Warning:
            prefixMessage = "警告"
            break
        case DDLogFlag.Error:
            prefixMessage = "錯誤"
            break
        default:
            break
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timeString = formatter.stringFromDate(NSDate())
        
        var fileInfo = ""
        let showImportantInfo = [DDLogFlag.Warning, DDLogFlag.Error]
        if(showImportantInfo.contains(logMessage.flag)){
            fileInfo = " (\(logMessage.fileName):\(logMessage.line))"
        }
        
        return "\(timeString) [\(prefixMessage)] > \(logMessage.message)\(fileInfo)"
    }
}