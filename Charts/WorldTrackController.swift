//
//  WorldTrackController.swift
//  Charts
//
//  Created by Admin on 8/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class WorldTrackController: UITableViewController {
    
    let scrollController = TableScrollController(resource: Track.topWorld, dataSource: UniversalTableViewController<Track, TrackTableViewCell>(cellId: "trackCell"))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.scrollController.dataSource
        self.tableView.delegate = self.scrollController
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 25
        self.scrollController.table = self.tableView
        self.scrollController.loadNextData(resource: Track.topWorld, countryName: nil)
        self.scrollController.tableSelectCallback = { [weak self] track, tableView, indexPath in
            self?.performSegue(withIdentifier: "ShowTrackInfoFromTop", sender: tableView.cellForRow(at: indexPath))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowTrackInfoFromTop", sender: tableView.cellForRow(at: indexPath))
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
