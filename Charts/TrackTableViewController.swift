//
//  TrackTableViewController.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit

class TrackTableViewController: NSObject, UITableViewDataSource {
    static let cellId = "trackCell"
    var tracks: [Track] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewController.cellId, for: indexPath)
        
        cell.imageView?.downloadedFrom(link: tracks[indexPath.row].image)
        cell.textLabel?.text = tracks[indexPath.row].name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = tracks[indexPath.row].artist
        
        return cell
    }
    
}
