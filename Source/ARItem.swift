//
//  ARItem.swift
//  KXAugmentedReality
//
//  Created by khan on 13/03/17.
//  Copyright © 2017 Appyte. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit



    open class ARItem  {
    
        public  var itemDescription: String?
        public var location: CLLocation?
        public var itemNode: SCNNode?
        
        
       public  init(itemDescription: String, location: CLLocation, itemNode: SCNNode? = nil) {
            
            self.itemDescription = itemDescription
            self.location = location
            self.itemNode = itemNode
        }
    
    }
    

