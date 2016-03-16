//
//  PracticeFrontViewController.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Async
import CocoaLumberjack

class PracticeFrontViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var topMapView: RunMapView!
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var locationManager: CLLocationManager!
    
    
    var highlightedPoints = [               // For testing only
        CLLocationCoordinate2DMake(22.215606, 114.214801),
        CLLocationCoordinate2DMake(22.216758, 114.214811),
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Practice Front View Controller 之 super.viewDidLoad() 已加載")
        
        
        topMapView.delegate = self
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
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