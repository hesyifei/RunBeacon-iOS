//
//  PracticeRecordViewController.swift
//  Run
//
//  Created by Jason Ho on 31/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import Alamofire
import CocoaLumberjack

class PracticeRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Record View Controller 之 super.viewDidLoad() 已加載")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = "row#\(indexPath.row)"
        cell.detailTextLabel!.text = "subtitle#\(indexPath.row)"
        
        return cell
    }
}