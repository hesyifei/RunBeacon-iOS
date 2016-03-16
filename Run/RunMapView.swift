//
//  RunMapView.swift
//  Run
//
//  Created by Jason Ho on 16/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import MapKit
import Async
import CocoaLumberjack

class RunMapView: MKMapView {
    
    let initLocation = CLLocation(latitude: 22.215417, longitude: 114.214779)
    
    var points = [
        CLLocationCoordinate2DMake(22.215606, 114.214801),
        CLLocationCoordinate2DMake(22.214672, 114.215133),
        CLLocationCoordinate2DMake(22.214791, 114.215884),
        CLLocationCoordinate2DMake(22.215944, 114.215766),
        CLLocationCoordinate2DMake(22.216758, 114.214811),
    ]
    
    
    
    let regionRadius: CLLocationDistance = 200
    
    var allAnnotations = [MKPointAnnotation]()
    
    
    
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
        
        for point in points {
            let objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = CLLocation(latitude: point.latitude, longitude: point.longitude).coordinate
            objectAnnotation.title = "#1 Big Field"
            objectAnnotation.subtitle = ""
            Async.main {
                self.addAnnotation(objectAnnotation)
            }
            
            allAnnotations.append(objectAnnotation)
        }
        
        
        var allPoints = points + [points[0]]
        let geodesic = MKGeodesicPolyline(coordinates: &allPoints[0], count: allPoints.count)
        self.addOverlay(geodesic)
        
        
        self.centerMapOnLocation(initLocation)
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
            pinView!.pinTintColor = pinColor
            
            let accessoryButton = UIButton(type: .DetailDisclosure)
            pinView!.rightCalloutAccessoryView = accessoryButton
        } else {
            pinView!.annotation = annotation
            pinView!.pinTintColor = pinColor
        }
        
        return pinView
    }
    
    func funcRegionDidChangeAnimated(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(mapView.region.span.latitudeDelta >= 0.04) || (mapView.region.span.latitudeDelta <= 0.001){
            centerMapOnLocation(initLocation)
        }
    }
}