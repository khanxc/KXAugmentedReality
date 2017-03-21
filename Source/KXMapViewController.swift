//
//  KXMapViewController.swift
//  KXAugmentedReality
//
//  Created by khan on 13/03/17.
//  Copyright © 2017 Appyte. All rights reserved.
//

import Foundation
import MapKit


 public  protocol KXMapViewDelegate {
    
   func kxMapViewItemTapped(pinItemTapped item: ARItem,currentUserLocation location: CLLocation)
    //func updateCurrentUserLocation(updatedUserLocation location: CLLocation)
}

extension KXMapViewDelegate {
    
    func updateCurrentUserLocation(updatedUserLocation location: CLLocation) {
        
    }
}

open  class KXMapViewController: UIViewController {
    
    

    
   open var targets: [ARItem] = [ARItem]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    

    open var kxAR: KXARViewController?
    open  var  kxDelegate: KXMapViewDelegate?
    
    
    public init(targets: [ARItem]) {
        super.init(nibName: nil, bundle: nil)
        self.targets = targets
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.userTrackingMode =  .followWithHeading
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
 
    
    
    public func setupLocations() {
        
        if targets.count > 0 {
            for item in targets {
                let annotation = MapAnnotation(location: (item.location?.coordinate)!, item: item)
                self.mapView.addAnnotation(annotation)
                } }
            else {
               // assertionFailure("\nTarget count is empty. Please add your dae files to target\n")
            }
    
        }
    
}

extension KXMapViewController: MKMapViewDelegate {
    
   
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        self.userLocation = userLocation.location
        
      
        if self.userLocation != nil {
          //  self.kxDelegate?.updateCurrentUserLocation(updatedUserLocation: self.userLocation!) 
        }
}
    
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
   
        let coordinate = view.annotation!.coordinate
   
        if let userCoordinate = userLocation {
        
        if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) < 50 {
           
            
  //Commenting out since the arguements are passed as Delegates 
            
            
            
                if let mapAnnotation = view.annotation as? MapAnnotation {
                    
                self.kxDelegate?.kxMapViewItemTapped(pinItemTapped: mapAnnotation.item, currentUserLocation: mapView.userLocation.location!)
                    
                    }
      
            }
        }
    }
}

