//
//  UniversalTableViewController.swift
//  Charts
//
//  Created by Admin on 9/6/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit

class UniversalTableViewController<Item, CellClass: UITableViewCell>: NSObject, UITableViewDataSource {
    let cellId: String
    var items: [Item] = []
    
    init(cellId: String) {
        self.cellId = cellId
    }
    
    var configureCell: ((CellClass, IndexPath, Item) -> Void)?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! CellClass
        
        configureCell?(cell, indexPath, items[indexPath.row])
        return cell
    }
    
}
