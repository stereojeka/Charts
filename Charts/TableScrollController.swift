//
//  TableScrollController.swift
//  Charts
//
//  Created by Admin on 9/6/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit

class TableScrollController: NSObject, UITableViewDelegate {
    
    var resource: Resource<[Track]>
    let dataSource: UniversalTableViewController<Track, TrackTableViewCell>
    var table: UITableView?
    var tableSelectCallback: ((Track, UITableView, IndexPath) -> Void)!
    var isDataLoading: Bool
    
    init(resource: Resource<[Track]>, dataSource: UniversalTableViewController<Track, TrackTableViewCell>) {
        self.resource = resource
        self.isDataLoading = false
        self.dataSource = dataSource
        self.table = nil
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (((self.table?.contentOffset.y)! + (self.table?.frame.size.height)!) >= (self.table?.contentSize.height)!) {
            if !isDataLoading {
                self.resource.page += 1
                loadNextData(resource: resource, countryName: resource.country)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableSelectCallback(dataSource.items[indexPath.row], tableView, indexPath)
    }
    
    func loadNextData(resource: Resource<[Track]>, countryName: String?) {
        Track.localTop.country = countryName
        Webservice().load(resource: resource) { [unowned self] result in
            if let result = result {
                self.dataSource.items.append(contentsOf: result)
                self.dataSource.configureCell = { cell, _, item in
                    cell.track = item
                    cell.updateContents()
                }
                self.isDataLoading = false
                self.table?.reloadData()
            } else {
                print("Service error.")
            }
        }
    }
    
}
