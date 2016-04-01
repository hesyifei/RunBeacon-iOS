//
//  RunMapView.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import Async
import CocoaLumberjack

class RunMapView: MKMapView {
    
    var defaults = NSUserDefaults()
    
    
    var initLocation = CLLocation()
    var regionRadius = CLLocationDistance()
    
    
    var allAnnotations = [MKPointAnnotation]()
    var allAnnotationsDict = [Int: MKPointAnnotation]()
    var allPoints = [CLLocationCoordinate2D]()
    
    
    var checkpointsGroupData = [Int: [Int]]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mapViewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        mapViewInit()
    }
    
    
    func varInit() {
        defaults = NSUserDefaults.standardUserDefaults()
        
        initLocation = CLLocation(latitude: self.defaults.doubleForKey("initLatitude"), longitude: self.defaults.doubleForKey("initLongitude"))
        
        regionRadius = 200.0
        
        checkpointsGroupData = CheckpointFunc().getCheckpointsGroup()
    }
    
    func mapViewInit() {
        varInit()
        
        self.mapType = .Satellite
        
        self.centerMapOnLocation(initLocation)
    }
    
    func loadCheckpoints(checkpoints: [Checkpoint]) {
        if(checkpoints.count > 0){
            for checkpoint in checkpoints {
                
                var canAddAnnotation = true
                for (_, groupData) in checkpointsGroupData {
                    if let index = groupData.indexOf(checkpoint.id) {
                        if(index >= 1){
                            canAddAnnotation = false
                        }
                    }
                }
                
                if(canAddAnnotation){
                    let objectAnnotation = MKPointAnnotation()
                    objectAnnotation.coordinate = checkpoint.coordinate
                    
                    if(checkpoint.id == 1){
                        // ID為1代表為起點（此處將不會有真正的iBeacon）
                        objectAnnotation.title = "Begin Ⓑ"
                    }else{
                        objectAnnotation.title = "Checkpoint \(checkpoint.id)"
                    }
                    
                    Async.main {
                        self.addAnnotation(objectAnnotation)
                    }
                    allAnnotations.append(objectAnnotation)
                    allAnnotationsDict[checkpoint.id] = objectAnnotation
                }
            }
            
            
            allPoints = allAnnotations.map {
                annotation -> CLLocationCoordinate2D in
                return annotation.coordinate
            }
            
            let geodesic = MKGeodesicPolyline(coordinates: &allPoints[0], count: allPoints.count)
            self.addOverlay(geodesic)
            
            
            
            let maxAndMinRepeatingCheckpointId = CheckpointFunc().getCheckpointsGroupMinAndMax()
            
            let coordinatesForClosingOneLine: [CLLocationCoordinate2D]!
            coordinatesForClosingOneLine = [
                (allAnnotationsDict[maxAndMinRepeatingCheckpointId["max"]!]?.coordinate)!,
                (allAnnotationsDict[maxAndMinRepeatingCheckpointId["min"]!]?.coordinate)!,
            ]
            
            // 添加繞圈時那條時圈閉合的線
            let closingOneLine = MKGeodesicPolyline(coordinates: &coordinatesForClosingOneLine[0], count: coordinatesForClosingOneLine.count)
            self.addOverlay(closingOneLine)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.setRegion(coordinateRegion, animated: true)
    }
    
    
    /** 這些func將需要於View Controller的delegate裡呼叫（這裡並沒有override delegate func） **/
    func funcRenderForOverlay(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(netHex: 0xFF6666)
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func funcViewForAnnotation(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation, allCheckpoints: [Checkpoint]) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        
        let reuseId = "pin"
        
        var pinColor = UIColor(netHex: 0xCCCCCC)
        if(annotation.coordinate.longitude == allCheckpoints[0].coordinate.longitude) && (annotation.coordinate.latitude == allCheckpoints[0].coordinate.latitude){
            pinColor = UIColor(netHex: 0xFF6666)
        }
        if(annotation.coordinate.longitude == allCheckpoints[allCheckpoints.count-1].coordinate.longitude) && (annotation.coordinate.latitude == allCheckpoints[allCheckpoints.count-1].coordinate.latitude){
            pinColor = UIColor(netHex: 0xFF6666)
        }
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.canShowCallout = true
        } else {
            pinView!.annotation = annotation
        }
        pinView!.pinTintColor = pinColor
        
        return pinView
    }
    
    func funcRegionDidChangeAnimated(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(mapView.region.span.latitudeDelta >= 0.04) || (mapView.region.span.latitudeDelta <= 0.001){
            centerMapOnLocation(initLocation)
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}