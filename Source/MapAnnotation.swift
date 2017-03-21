//
//  MapAnnotation.swift
//  KXAugmentedReality
//
//  Created by khan on 13/03/17.
//  Copyright © 2017 Appyte. All rights reserved.
//

import Foundation

import MapKit

class MapAnnotation: NSObject, MKAnnotation {

    let coordinate: CLLocationCoordinate2D
    let title: String?
    let item: ARItem
   
    init(location: CLLocationCoordinate2D, item: ARItem) {
        self.coordinate = location
        self.item = item
        self.title = item.itemDescription
        
        super.init()
    }
}
