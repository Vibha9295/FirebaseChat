//
//  MapPoint.swift
//  SwiftChat_FireBase
//
//  Created by jayati on 8/1/17.
//  Copyright © 2017 com.zaptechsolutions. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class MapPoint: NSObject, MKAnnotation {
  
    var name: String = ""
    var address: String = ""
    var coordinate = CLLocationCoordinate2D()
    init(name: String, address: String, coordinate: CLLocationCoordinate2D) {
            super.init()
            self.name = name.copy() as! String
            self.address = address.copy() as! String
            self.coordinate = coordinate
        }
    
    func title() -> String {
        if (name is NSNull) {
            return "Unknown charge"
        }
        else {
            return name
        }
    }
    
    func subtitle() -> String {
        return address
    }
}
