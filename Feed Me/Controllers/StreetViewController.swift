//
//  StreetViewController.swift
//  Feed Me
//
//  Created by Aaron Monick on 3/2/15.
//  Copyright (c) 2015 Ron Kliffer. All rights reserved.
//

import UIKit

class StreetViewController: UIViewController, GMSMapViewDelegate {
  
    var coordinate: CLLocationCoordinate2D?
    var marker: PlaceMarker?
  
    override func viewDidLoad() {
      var panoView = GMSPanoramaView(frame: CGRectZero)
      self.view = panoView
    
      //panoView.moveNearCoordinate(CLLocationCoordinate2DMake(-33.732, 150.312))
      panoView.moveNearCoordinate(coordinate!)
    
      if marker != nil {
        marker?.panoramaView = panoView
      }
    }

}