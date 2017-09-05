//
//  WorldTrackController.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class WorldTrackController: UITableViewController {
    
    var isDataLoading: Bool = false
    let controller = TrackTableViewController()
    
    func loadTopWorldTracks() {
        Webservice().load(resource: Track.topWorld) { [unowned self] result in
            if let result = result {
                self.controller.tracks.append(contentsOf: result)
                self.tableView.reloadData()
            }else{
                print("Service error.")
            }
        }
        Track.topWorld.page += 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = controller
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 25
        loadTopWorldTracks()
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
                loadTopWorldTracks()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowTrackInfoFromTop", sender: tableView.cellForRow(at: indexPath))
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
