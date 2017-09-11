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
    
    let scrollController = TableScrollController(resource: Track.localTop, dataSource: UniversalTableViewController<Track, TrackTableViewCell>(cellId: "trackCell"))
    
    let locationController = LocationManager()

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
            locationController.locationManager.requestWhenInUseAuthorization()
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
        
        locationController.startLocationManager()
        locationController.countryReceivedCallback = { [unowned self] country in
            self.scrollController.loadNextData(resource: self.scrollController.resource, countryName: country)
            self.scrollController.resource.page += 1
            self.navigationItem.title = "\(country) Top Tracks"
        }
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
