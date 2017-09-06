//
//  LocalTrackController.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreLocation

class LocalTrackController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    let scrollController = TableScrollController(resource: Track.localTop, dataSource: UniversalTableViewController<Track, TrackTableViewCell>(cellId: "trackCell"))
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailwithError\(error)")
        stopLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations.last!
        
        if latestLocation.horizontalAccuracy < 0 {
            return
        }
        if location == nil || location!.horizontalAccuracy > latestLocation.horizontalAccuracy {
            
            location = latestLocation
            stopLocationManager()
            
            geocoder.reverseGeocodeLocation(latestLocation, completionHandler: { (placemarks, error) in
                if error == nil, let placemark = placemarks, !placemark.isEmpty {
                    self.placemark = placemark.last
                }
                
                self.parsePlacemarks()
                
            })
        }
    }
    
    func parsePlacemarks() {
        if let _ = location {
            if let placemark = placemark {
                if let country = placemark.country, !country.isEmpty {
                    self.scrollController.loadNextData(resource: self.scrollController.resource, countryName: country)
                    self.scrollController.resource.page += 1
                    self.navigationItem.title = "\(country) Top Tracks"
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.scrollController.dataSource
        self.tableView.delegate = self.scrollController
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 25
        self.scrollController.table = self.tableView
        
        self.scrollController.tableSelectCallback = { [weak self] track, tableView, indexPath in
            self?.performSegue(withIdentifier: "ShowTrackInfoFromLocal", sender: tableView.cellForRow(at: indexPath))
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if authStatus == .denied || authStatus == .restricted {
            let alertController = UIAlertController(title: "Location Manager",
                                                    message: "You need to give location permissions in order get top tracks in your country", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel,
                                         handler: { action in })
            alertController.addAction(okAction)
            present(alertController, animated: true,
                    completion: nil)
        }
        
        startLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let infoVC = segue.destination as! TrackInfoViewController
        infoVC.navigationItem.title = scrollController.dataSource.items[indexPath.row].name
        infoVC.track = scrollController.dataSource.items[indexPath.row]
    }

}
