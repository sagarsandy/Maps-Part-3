//
//  ViewController.swift
//  Maps Part 3
//
//  Created by Sagar Sandy on 27/11/18.
//  Copyright © 2018 Sagar Sandy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapViewOutlet: MKMapView!
    
    // User defined variables
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initializing location manager delegate
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Setting up location manager properties
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Initializing mapview delegate
        mapViewOutlet.delegate = self
        
        // Setting up mapview properties
        mapViewOutlet.showsUserLocation = true
        
    }
    
    

    @IBAction func addButtonPressed(_ sender: Any) {
        
        let alertVC = UIAlertController(title: "Enter Address", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            if let textField = alertVC.textFields?.first {
                
                self.reverseGeoCode(address : textField.text!) { (placemark) in
                    
                    print("hello 1")
                    let destinationPlaceMark = MKPlacemark(coordinate: (placemark.location?.coordinate)!)
                    
                    let startingMapItem = MKMapItem.forCurrentLocation()
                    let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
                    
                    let directionsReq = MKDirections.Request()
                    directionsReq.transportType = .automobile
                    directionsReq.source = startingMapItem
                    directionsReq.destination = destinationMapItem
                    
                    let directions = MKDirections(request: directionsReq)
                    
                    directions.calculate(completionHandler: { (response, error) in
                        
                        print("hello2")
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        guard let response = response,
                            let route = response.routes.first else {
                            return
                        }
                        
                        if !route.steps.isEmpty {
                            
                            for step in route.steps {
                                print(step.instructions)
                            }
                        }
                        
                        // Directions overlay
                        self.mapViewOutlet.addOverlay(route.polyline, level: .aboveRoads)
                        // Note: As of now, directions will not be returned for india, apple is not supported for directions in india
                    })
                    
                    
                    
                    
                    // Opening the user entered location with default phone map app
//                    MKMapItem.openMaps(with: [destinationMapItem], launchOptions: nil)
                }
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in }
        
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: Reverse geo coding, fetching lat and long based on entered address
    func reverseGeoCode(address : String, completion : @escaping (CLPlacemark) -> ()) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placeMarks, error) in
            
            if let error = error {
                print(error)
                
                return
            }
            
            guard let placemarks = placeMarks,
                let placemark = placemarks.first else {
                    return
            }
            
            self.addAnnoatationToMapBasedOnPlacemark(placemark: placemark)
            
            completion(placemark)
            
        }
    }
    
    // MARK: Add annoation to the mapview based on fetched placemarks
    func addAnnoatationToMapBasedOnPlacemark(placemark : CLPlacemark) {
        
        if let coordinate = placemark.location?.coordinate {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapViewOutlet.addAnnotation(annotation)
            
        }
        
    }
    
    
    // MARK: Delegate method for rendering overlay(directions road)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderOverlay = MKPolylineRenderer(overlay: overlay)
        renderOverlay.lineWidth = 5.0
        renderOverlay.strokeColor = UIColor.cyan
        return renderOverlay
        
    }
    
    // MARK: Checking user gave permission or not for locations
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("yup")
        } else {
            print("something went wrong")
        }
    }
    
}

// MARK: Map view delegate methods extension

extension ViewController : MKMapViewDelegate {
    
    // This method will be called upon updating user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        // Zooming into current user location
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        
        
        print("user location changed")
    }
    
    // This method will return locations even in background mode also, didupdate user location will not fire in background mode. We need to use this method to get backgound location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location changed again")
        
        
    }
        
}

