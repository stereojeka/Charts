//
//  WorldTrackController.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class WorldTrackController: UITableViewController {
    
    private var trackService: TrackService!
    var isDataLoading: Bool = false
    var currentPage: Int = 0
    var totalPages: Int = 1
    let controller = TrackTableViewController()
    
    func loadMoreTracks() {
        if var urlComponents = URLComponents(string: "https://ws.audioscrobbler.com/2.0/") {
            urlComponents.query = "method=chart.gettoptracks&page=\(currentPage+1)&api_key=55b8c3a1d79ea8d23fd7bf19596ed6d1&format=json"
            if let url = urlComponents.url {
                trackService.getTopTracks(url) {
                    [unowned self] results, pageIndex, totalPages, errorMessage in
                    if let results = results {
                        self.controller.tracks.append(contentsOf: results)
                        self.tableView.reloadData()
                        self.currentPage = pageIndex + 1
                        self.totalPages = totalPages
                        if !errorMessage.isEmpty { print("Service error: " + errorMessage); }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = controller
        trackService = TrackService.sharedTrackService
        loadMoreTracks()
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
            if !isDataLoading && currentPage != totalPages {
                isDataLoading = true
                loadMoreTracks()
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
    }

}
