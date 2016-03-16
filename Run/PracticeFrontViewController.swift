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

class PracticeFrontViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var topMapView: RunMapView!
    @IBOutlet var startButton: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var locationManager: CLLocationManager!
    
    
    var checkpointsData = [Checkpoint]()
    
    var highlightedPoints = [               // For testing only
        CLLocationCoordinate2DMake(22.215606, 114.214801),
        CLLocationCoordinate2DMake(22.216758, 114.214811),
    ]
    
    
    // TODO: USE CLASS TO STORE/GET VALUE FOR EACH CHECKPOINT & TRIP
    // TODO: ADD TWO KINDS OF MODE 1. LIKE CURRENT 2. 橫向表格、顯示每次chekcpoint間的時間及標準時間
    // TODO: USE UIIMAGEVIEW TO SHOW REDCROSS/WATER IN ASSES VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Front View Controller 之 super.viewDidLoad() 已加載")
        
        
        topMapView.delegate = self
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
        
        startButton.titleLabel?.text = "Start"
        startButton.titleLabel?.font = UIFont(name: (startButton.titleLabel?.font?.fontName)!, size: 30.0)
        startButton.backgroundColor = UIColor.greenColor()
        
        
        
        initCheckpointsData()
    }
    
    func initCheckpointsData() {
        Alamofire.request(.GET, "http://areflys-mac.local/checkpoints.json")
            .response { request, response, data, error in
                /*print(request)
                print(response)
                print(data)
                print(error)*/
                if let error = error {
                    DDLogError("Checkpoints數據獲取錯誤：\(error)")
                } else {
                    let json = JSON(data: data!)
                    for (_, subJson): (String, JSON) in json["checkpoints"] {
                        self.checkpointsData.append(Checkpoint(json: subJson))
                    }
                    
                    self.topMapView.setAnnotations(self.checkpointsData)
                }
        }
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return topMapView.funcRenderForOverlay(mapView, rendererForOverlay: overlay)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return topMapView.funcViewForAnnotation(mapView, viewForAnnotation: annotation, highlightedPoints: highlightedPoints)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        topMapView.funcRegionDidChangeAnimated(mapView, regionDidChangeAnimated: animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}