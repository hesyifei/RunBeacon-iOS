//
//  PracticeFrontViewController.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MapKit
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON
import MBProgressHUD

class PracticeFrontViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // TODO: USE CLASS TO STORE/GET VALUE FOR EACH CHECKPOINT & TRIP
    // TODO: ADD TWO KINDS OF MODE 1. LIKE CURRENT 2. 橫向表格、顯示每次chekcpoint間的時間及標準時間
    // TODO: USE UIIMAGEVIEW TO SHOW REDCROSS/WATER IN MKANNOTION ASSES VIEW
    // TODO: 通過json寫入每段距離/標準時間/標準速度etc
    
    
    // MARK: - IBOutlet var
    @IBOutlet var topMapView: RunMapView!
    @IBOutlet var startButton: UIButton!
    
    
    // MARK: - Basic var
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var locationManager: CLLocationManager!
    
    
    // MARK: - Data var
    var tripId = ""
    
    var checkpointsData = [Checkpoint]()
    
    var highlightedPoints = [               // For testing only
        CLLocationCoordinate2DMake(22.215606, 114.214801),
        CLLocationCoordinate2DMake(22.216758, 114.214811),
    ]
    
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Front View Controller 之 super.viewDidLoad() 已加載")
        
        
        startButton.addTarget(self, action: "startButtonAction", forControlEvents: .TouchUpInside)

        
        
        topMapView.delegate = self
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        startButton.titleLabel?.text = "Start"
        startButton.titleLabel?.font = UIFont(name: (startButton.titleLabel?.font?.fontName)!, size: 30.0)
        startButton.backgroundColor = UIColor.greenColor()
        
        
        initCheckpoints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("Practice Front View Controller 之 super.viewWillAppear() 已加載")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? PracticeRunningViewController {
            destinationVC.tripId = self.tripId
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Action func
    func startButtonAction() {
        MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        Alamofire.request(.GET, BasicConfig.RunCheckTripIdGetURL)
            .responseString { response in
                if(response.result.isSuccess){
                    self.tripId = response.result.value!
                    DDLogDebug("已從服務器獲取此次TripId：\(self.tripId)")
                    self.performSegueWithIdentifier("showPracticeRunningView", sender: self)
                }else{
                    DDLogError("從服務器獲取TripId失敗")
                }
                MBProgressHUD.hideHUDForView(self.navigationController?.view, animated: true)
        }
    }
    
    
    // MARK: - Data func
    func initCheckpoints() {
        checkpointsData = CheckpointFunc().getCheckpoints()
        topMapView.loadCheckpoints(checkpointsData)
    }
    
    
    // MARK: - MapView func
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return topMapView.funcRenderForOverlay(mapView, rendererForOverlay: overlay)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return topMapView.funcViewForAnnotation(mapView, viewForAnnotation: annotation, highlightedPoints: highlightedPoints)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        topMapView.funcRegionDidChangeAnimated(mapView, regionDidChangeAnimated: animated)
    }
}