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
    
    let initLocation = CLLocation(latitude: 22.215417, longitude: 114.214779)
    
    
    
    let regionRadius: CLLocationDistance = 200
    
    var allAnnotations = [MKPointAnnotation]()
    var allPoints = [CLLocationCoordinate2D]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mapViewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        mapViewInit()
    }
    
    
    
    func mapViewInit() {
        self.mapType = .Satellite
        
        self.centerMapOnLocation(initLocation)
    }
    
    func loadCheckpoints(checkpoints: [Checkpoint]) {
        if(checkpoints.count > 0){
            for checkpoint in checkpoints {
                let objectAnnotation = MKPointAnnotation()
                objectAnnotation.coordinate = checkpoint.coordinate
                objectAnnotation.title = "#\(checkpoint.id) \(checkpoint.name)"
                objectAnnotation.subtitle = checkpoint.detail
                Async.main {
                    self.addAnnotation(objectAnnotation)
                }
                
                allAnnotations.append(objectAnnotation)
            }
            
            
            allPoints = allAnnotations.map {
                annotation -> CLLocationCoordinate2D in
                return annotation.coordinate
            }
            
            var allPointsWithFinish = allPoints + [allPoints[0]]
            let geodesic = MKGeodesicPolyline(coordinates: &allPointsWithFinish[0], count: allPointsWithFinish.count)
            self.addOverlay(geodesic)
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
            polylineRenderer.strokeColor = UIColor.redColor()
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func funcViewForAnnotation(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation, highlightedPoints: [CLLocationCoordinate2D]) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        
        let reuseId = "pin"
        
        var pinColor = UIColor.greenColor()
        for point in highlightedPoints {
            if(annotation.coordinate.longitude == point.longitude) && (annotation.coordinate.latitude == point.latitude){
                pinColor = UIColor.yellowColor()
            }
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            
            let accessoryButton = UIButton(type: .DetailDisclosure)
            pinView!.rightCalloutAccessoryView = accessoryButton
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