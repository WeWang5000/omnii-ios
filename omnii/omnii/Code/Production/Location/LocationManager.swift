//
//  LocationManager.swift
//  omnii
//
//  Created by huyang on 2023/6/5.
//

import Foundation
import CoreLocation
import PopupDialog

final class LocationManager: NSObject {
    
    var updateLocationCoordinate: ((CLLocationCoordinate2D) -> Void)?
    
    var status: CLAuthorizationStatus = .notDetermined
    var userLocation: CLLocation?
    var userCoordinate: CLLocationCoordinate2D?
    
    static let shared = LocationManager.init()
    
    private var locationManager : CLLocationManager?
    
    func didUpdateLocation() {
        
        guard let location = locationManager else {
            self.requestLocationServicesAuthorization()
            return
        }
        
        if #available(iOS 14.0, *) {
            status = location.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        guard (status == .authorizedAlways || status == .authorizedWhenInUse) else {
            self.requestLocationServicesAuthorization()
            return
        }
        
        updatingLocation()
    }
        
    private func requestLocationServicesAuthorization() {
        
        if (self.locationManager == nil) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
        }
        
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            locationManager?.requestWhenInUseAuthorization()
        }
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            let distance : CLLocationDistance = 100.0
            locationManager?.distanceFilter = distance
            locationManager?.startUpdatingLocation()
        }
        
    }
    
    private func updatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    private func reportLocationServicesAuthorizationStatus(status:CLAuthorizationStatus) {
        self.status = status
        if status == .notDetermined {
            // 未决定,继续请求授权
            requestLocationServicesAuthorization()
        } else if (status == .restricted) {
            // 受限制，尝试提示然后进入设置页面进行处理
            showAlert()
        } else if (status == .denied) {
            // 受限制，尝试提示然后进入设置页面进行处理
            showAlert()
        }
    }
    
    private func showAlert() {
        let title = "Omnii wants  to use your location"
        let message = "Omnii uses this way to customize the user experience for you, allowing you to discover more exciting content around you."
        let popup = PopupDialog(title: title,
                                message: message,
                                transitionStyle: .alert)
        let cancel = CancelButton(title: "Cancel", action: nil)
        let confirm = GradientButton(title: "GO") {
            guard let url = NSURL.init(string: UIApplication.openSettingsURLString) as? URL else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        popup.addButtons([cancel, confirm])
        UIApplication.shared.topMostViewController()?.present(popup, animated: true)
    }
    
}


extension LocationManager:  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager?.stopUpdatingLocation()
        
        let location = locations.last ?? CLLocation.init()
        userLocation = location
        
        let coordinate = location.coordinate
        userCoordinate = coordinate
        
        updateLocationCoordinate?(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        reportLocationServicesAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager?.stopUpdatingLocation()
    }
}
