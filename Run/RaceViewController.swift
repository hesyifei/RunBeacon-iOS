//
//  RaceViewController.swift
//  Run
//
//  Created by Jason Ho on 10/4/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON
import MBProgressHUD

class RaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var tableView: UITableView!
    
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    
    
    // MARK: - Data var
    var passData = [String]()
    
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Race View Controller 之 super.viewDidLoad() 已加載")
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        passData = ["haha", "wata"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Tableview func
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PassCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = "YAYA\(passData[indexPath.row])"
        cell.detailTextLabel!.text = "WOHO"
        
        return cell
    }
}