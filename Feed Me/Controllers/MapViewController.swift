//
//  MapViewController.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, /*TypesTableViewControllerDelegate*/FilterViewControllerDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, ENSideMenuDelegate {
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  let dataProvider = GoogleDataProvider()
  let locationManager = CLLocationManager()
  
  var selectedCoordinates: CLLocationCoordinate2D?
  var selectedPlacemarker: PlaceMarker?
  
    var mapRadius: Double {
    get {
      let region = mapView.projection.visibleRegion()
      let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
      let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
      return max(horizontalDistance, verticalDistance)*0.5
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.sideMenuController()?.sideMenu?.delegate = self
    // Do any additional setup after loading the view, typically from a nib.
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
    mapView.delegate = self
  }
  
  @IBAction func mapTypeSegmentPressed(sender: AnyObject) {
    let segmentedControl = sender as UISegmentedControl
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      mapView.mapType = kGMSTypeNormal
    case 1:
      mapView.mapType = kGMSTypeSatellite
    case 2:
      mapView.mapType = kGMSTypeHybrid
    default:
      mapView.mapType = mapView.mapType
    }
  }
  
  // MARK: - CLLocationManager Delegate
  // 1
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    // 2
    if status == .AuthorizedWhenInUse {
      
      // 3
      locationManager.startUpdatingLocation()
      
      //4
      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true
    }
  }
  
  // 5
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if let location = locations.first as? CLLocation {
      //reload places around location
      fetchNearbyPlaces(location.coordinate)
      // 6
      mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
      
      // 7
      locationManager.stopUpdatingLocation()
    }
  }
  
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
          self.addressLabel.unlock()
          if let address = response?.firstResult() {
                
                // 3
                let lines = address.lines as [String]
                self.addressLabel.text = join("\n", lines)
                
                // 4
                let labelHeight = self.addressLabel.intrinsicContentSize().height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                    
                UIView.animateWithDuration(0.25) {
                    self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 2)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
  //MARK: - GMSMapViewDelegate
  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    reverseGeocodeCoordinate(position.target)
  }
  
  func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
    addressLabel.lock()
    
    if (gesture) {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
    }
  }
  
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        // 1
        let placeMarker = marker as PlaceMarker
        
        // 2
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            // 3
            infoView.nameLabel.text = placeMarker.place.name
            
            // 4
            if let photo = placeMarker.place.photo {
                infoView.placePhoto.image = photo
            } else {
                infoView.placePhoto.image = UIImage(named: "generic")
            }
            
            return infoView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }
  
  func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
    let placeMarker = marker as PlaceMarker
    selectedCoordinates = placeMarker.place.coordinate
    selectedPlacemarker = placeMarker
    performSegueWithIdentifier("Street View", sender: self)
  }
  
  func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
    selectedCoordinates = coordinate
    performSegueWithIdentifier("Street View", sender: self)
  }
    
  //from Google Places API
  func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    // 1
    mapView.clear()
    // 2
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:mapRadius, types: searchedTypes) { places in
      for place: GooglePlace in places {
        // 3
        let marker = PlaceMarker(place: place)
        // 4
        marker.map = self.mapView
      }
    }
  }
  
  func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
      mapCenterPinImage.fadeIn(0.25)
      mapView.selectedMarker = nil
      return false
  }
    
  //MARK: - Navigation Controller Delegate
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == "Types Segue" {
//      let navigationController = segue.destinationViewController as UINavigationController
//      let controller = segue.destinationViewController.topViewController as TypesTableViewController
//      controller.selectedTypes = searchedTypes
//      controller.delegate = self
//    }
    if segue.identifier == "Street View" {
      let navigationController = segue.destinationViewController as UINavigationController
      let controller = segue.destinationViewController.topViewController as StreetViewController
      controller.coordinate = selectedCoordinates
      if selectedPlacemarker != nil {
            controller.marker = selectedPlacemarker
      }
      //controller.delegate = self
    }
  }
  
  // MARK: - Types Controller Delegate
//  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
//    searchedTypes = sorted(controller.selectedTypes)
//    dismissViewControllerAnimated(true, completion: nil)
//    //reload places bases on new selected types
//    fetchNearbyPlaces(mapView.camera.target)
//  }
  
  // MARK: - Types Controller Delegate
  func filterController(controller: FilterViewController, didSelectTypes types: [String]) {
    searchedTypes = sorted(controller.selectedTypes)
    //dismissViewControllerAnimated(true, completion: nil)
    //reload places bases on new selected types
    fetchNearbyPlaces(mapView.camera.target)
    
  }
  
    @IBAction func refresh(sender: AnyObject) {
        //fetchNearbyPlaces(mapView.camera.target)
        toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        println("sideMenuShouldOpenSideMenu")
        return true;
    }
}

