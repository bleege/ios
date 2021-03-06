//
//  LocationManager.swift
//  ios-sdk
//
//  Created by Matt Smollinger on 11/22/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import UIKit
import CoreLocation
import OnTheRoad

extension OTRGeoPoint {
  
}

@objc public protocol LocationManagerDelegate {
  optional func authorizationDidSucceed()
  optional func authorizationDenied()
  optional func authorizationRestricted()
  optional func locationDidUpdate(location: CLLocation)
}


public class LocationManager: NSObject, CLLocationManagerDelegate {

  public static let sharedManager = LocationManager()
  public var currentLocation: CLLocation?
  public weak var delegate: LocationManagerDelegate?

  private let coreLocationManager = CLLocationManager()
  private override init(){
    super.init()
    coreLocationManager.delegate = self
  }

  public func requestAlwaysAuthorization() {
    coreLocationManager.requestAlwaysAuthorization()

  }

  public func requestWhenInUseAuthorization() {
    coreLocationManager.requestWhenInUseAuthorization()
  }

  public func isInUseAuthorized() -> Bool {
    return CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse ? true :  false
  }

  public func isAlwaysAuthorized() -> Bool {
        return CLLocationManager.authorizationStatus() == .AuthorizedAlways ? true :  false
  }

  public func refreshCurrentLocation() -> CLLocation? {
    if CLLocationManager.locationServicesEnabled() &&
      (CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
      currentLocation = coreLocationManager.location
      return coreLocationManager.location
    }
    return nil
  }

  //The difference between this function and the one above is requestLocation() immediately returns and will serve the location via the delegate
  public func requestLocation() {
    coreLocationManager.requestLocation()
  }

  public func startUpdatingLocation() {
    coreLocationManager.startUpdatingLocation()
  }

  public func stopUpdatingLocation() {
    coreLocationManager.stopUpdatingLocation()
  }

  //MARK: - CLLocationManagerDelegate

  public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .AuthorizedAlways:
      delegate?.authorizationDidSucceed?()
    case .AuthorizedWhenInUse:
      manager.startUpdatingLocation()
      delegate?.authorizationDidSucceed?()
    case .Denied:
      delegate?.authorizationDenied?()
    case .Restricted:
      delegate?.authorizationRestricted?()
    default:
      print("Not Authorized")
    }
  }

  public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      currentLocation = location
      delegate?.locationDidUpdate?(location)
    }
  }

  public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error from location manager: \(error)")
  }

}
