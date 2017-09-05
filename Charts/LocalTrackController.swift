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
    
    var country: String? {
        didSet {
            loadLocalTopTracks(countryName: country!)
        }
    }
    
    var isDataLoading: Bool = false
    let controller = TrackTableViewController()
    
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
                    self.country = country
                }
            }
        }
    }
    
    func loadLocalTopTracks(countryName: String){
        Track.localTop.country = countryName
        Webservice().load(resource: Track.localTop){ [unowned self] result in
            if let result = result {
                self.controller.tracks.append(contentsOf: result)
                self.tableView.reloadData()
                self.navigationItem.title = "\(countryName) Top Tracks"
            }else{
                print("Service error.")
            }
        }
        Track.localTop.page += 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = controller
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 25
        
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

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        {
            if !isDataLoading {
                isDataLoading = true
                if let country = country {
                    loadLocalTopTracks(countryName: country)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowTrackInfoFromLocal", sender: tableView.cellForRow(at: indexPath))
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let infoVC = segue.destination as! TrackInfoViewController
        infoVC.navigationItem.title = controller.tracks[indexPath.row].name
        infoVC.trackName = controller.tracks[indexPath.row].name
        infoVC.artistName = controller.tracks[indexPath.row].artist
        infoVC.imageLink = controller.tracks[indexPath.row].largeImage
        infoVC.track = controller.tracks[indexPath.row]
    }

}
